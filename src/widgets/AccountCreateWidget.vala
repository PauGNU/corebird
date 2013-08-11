/*  This file is part of corebird, a Gtk+ linux Twitter client.
 *  Copyright (C) 2013 Timm Bäder
 *
 *  corebird is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  corebird is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with corebird.  If not, see <http://www.gnu.org/licenses/>.
 */


using Gtk;

// TODO: If the account is open in a MainWindow instance, either close that window or
//       diable the remove button
[GtkTemplate (ui = "/org/baedert/corebird/ui/account-create-widget.ui")]
class AccountCreateWidget : Gtk.Grid {
  [GtkChild]
  private Entry pin_entry;
  private unowned Account acc;
  public signal void result_received (bool result, Account acc);

  public AccountCreateWidget (Account acc){
    this.acc = acc;
  }

  [GtkCallback]
  private void request_pin_button_clicked () {
    acc.init_proxy (false);
    try {
      acc.proxy.request_token ("oauth/request_token", "oob");
      string uri = "http://twitter.com/oauth/authorize?oauth_token="+acc.proxy.get_token();
      message ("Trying to open %s", uri);
      GLib.AppInfo.launch_default_for_uri(uri, null);
    } catch (GLib.Error e) {
      Utils.show_error_dialog (e.message);
      critical (e.message);
    }
  }

  [GtkCallback]
  private void confirm_button_clicked () {
    try {
      acc.proxy.access_token("oauth/access_token", pin_entry.get_text());
    } catch (GLib.Error e) {
      critical (e.message);
      result_received (false, acc);
      return;
    }
    
    // The token and token secret have been successfully received
    // So, get some account information
    var call = acc.proxy.new_call ();
    call.set_function ("1.1/account/settings.json");
    call.set_method ("GET");
    call.invoke_async.begin (null, (obj, res) => {
      message ("settings call");
      var parser = new Json.Parser ();
      try {
        parser.load_from_data (call.get_payload ());
      } catch (GLib.Error e) {
        critical ("Problem with JSON Data: %s\n%s", e.message, call.get_payload ());
      } 
      var root = parser.get_root ().get_object ();
      string screen_name = root.get_string_member ("screen_name");

      unowned GLib.SList<Account> current_accounts = Account.list_accounts ();
      foreach (var a in current_accounts) {
        if (a.screen_name == screen_name)
          critical ("Account is already in use");
          // TODO: Show a dialog here
          //       Remove the used AccountCreateWidget again.
      }

      acc.query_user_info_by_scren_name.begin (screen_name, (obj, res) => {
        acc.query_user_info_by_scren_name.end (res);
        message ("user info call");
        acc.init_database ();
        acc.save_info();
        try {
          acc.db.execute ("INSERT INTO `common`(token, token_secret) VALUES ('%s', '%s');"
                          .printf (acc.proxy.token, acc.proxy.token_secret));
          // TODO: Insert account into app menu
        } catch (SQLHeavy.Error e) {
          critical (e.message);
        }
        result_received (true, acc);
      });
    });
  }

}