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


/**
 * Page in a MainWindow(i.e. in the MainWindow's GtkStack).
 */
public interface IPage : Gtk.Widget {
  public abstract int id { get; set; }
  public abstract void on_join(int page_id, va_list arg_list);
  public abstract void on_leave ();
  public abstract void create_tool_button(Gtk.RadioButton? group);
  public abstract Gtk.RadioButton? get_tool_button();
  public abstract string? get_title ();
  public abstract unowned MainWindow main_window {get; set;}
  public abstract unowned Account account        {get; set;}




  public virtual bool handles_double_open () {
    return false;
  }

  public virtual void double_open () {}
}
