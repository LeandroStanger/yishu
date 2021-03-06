/*
* Copyright (c) 2017 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
using Gtk;

namespace Yishu {
	public class MainWindow : Gtk.Window {
		public Gtk.Box info_bar_box;
		public Gtk.HeaderBar toolbar;
		public Gtk.Button open_button;
		public Gtk.Button add_button;
		public Granite.Widgets.Welcome welcome;
		public Granite.Widgets.Welcome no_file;
		public Gtk.TreeView tree_view;
		public Gtk.CellRendererToggle cell_renderer_toggle;

        public MainWindow (Gtk.Application application) {
            GLib.Object (
                            application: application,
                            icon_name: "com.github.lainsce.yishu",
                            height_request: 600,
                            width_request: 600,
                            title: _("Yishu")
                        );
        }

        construct {
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/lainsce/yishu/stylesheet.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            var settings = AppSettings.get_default ();
            int x = settings.window_x;
            int y = settings.window_y;

            if (x != -1 && y != -1) {
                move (x, y);
            }

            if (Gtk.get_minor_version() < 20) {
			    set_default_size (settings.saved_state_width, settings.saved_state_height);
            } else {
                if (settings.saved_state_height != -1 ||  settings.saved_state_width != -1) {
                    var rect = Gtk.Allocation ();
                    rect.height = settings.saved_state_height;
                    rect.width = settings.saved_state_width;
                    set_allocation (rect);
                }
            }

			var vbox = new Box(Gtk.Orientation.VERTICAL, 0);
			var stack = new Stack();
			var swin = new ScrolledWindow(null, null);

			welcome = new Granite.Widgets.Welcome("No Todo.txt File Open", _("Open a todo.txt file to start adding tasks"));
      welcome.append("appointment-new", _("Add task"), _("Create a new todo.txt file with this task in your Home folder"));
			welcome.append("help-contents", _("What is a todo.txt file?"), _("Learn more about todo.txt files"));

			no_file = new Granite.Widgets.Welcome("No Todo.txt File Found", _("Add tasks to start this todo.txt file"));

			/* Create toolbar */
			toolbar = new HeaderBar();
            this.set_titlebar(toolbar);
            toolbar.set_show_close_button (true);
            toolbar.has_subtitle = false;
            toolbar.set_title("Yishu");

			add_button = new Gtk.Button ();
            add_button.set_image (new Gtk.Image.from_icon_name ("appointment-new", Gtk.IconSize.LARGE_TOOLBAR));
            add_button.has_tooltip = true;
            add_button.tooltip_text = (_("Add task…"));

			var menu_button = new Gtk.Button ();
			menu_button.has_tooltip = true;
			menu_button.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
			menu_button.tooltip_text = (_("Settings"));
			menu_button.clicked.connect (() => {
					debug ("Prefs button pressed.");
					var preferences_dialog = new Widgets.Preferences (this);
					preferences_dialog.show_all ();
			});
			toolbar.pack_start(add_button);
			toolbar.pack_end (menu_button);

			tree_view = setup_tree_view();
			swin.add(tree_view);
			stack.add(welcome);
			stack.add(swin);

			info_bar_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			vbox.pack_start(info_bar_box, false, false, 0);
			vbox.pack_start(stack, true, true, 0);
			add(vbox);

			show_all();
		}

        public override bool delete_event (Gdk.EventAny event) {
            int x, y;
            int w, h;
            Gtk.Allocation rect;
            var settings = AppSettings.get_default ();

            if (Gtk.get_minor_version() < 20) {
                get_position (out x, out y);
                get_size(out w, out h);

                settings.window_x = x;
                settings.window_y = y;
                settings.saved_state_width = w;
                settings.saved_state_height = h;
            } else {
                get_position (out x, out y);
                get_allocation (out rect);

                settings.saved_state_width = rect.width;
                settings.saved_state_height = rect.height;
                settings.window_x = x;
                settings.window_y = y;
            }
            return false;
        }

		private TreeView setup_tree_view(){
			TreeView tv = new TreeView();
			TreeViewColumn col;

			col = new TreeViewColumn.with_attributes(_("Priority"), new Granite.Widgets.CellRendererBadge(), "text", Columns.PRIORITY);
			col.set_sort_column_id(Columns.PRIORITY);
			col.resizable = true;
			tv.append_column(col);

			col = new TreeViewColumn.with_attributes(_("Task"), new CellRendererText(), "markup", Columns.MARKUP);
			col.set_sort_column_id(Columns.MARKUP);
			col.resizable = true;
            col.expand = true;
			tv.append_column(col);

			cell_renderer_toggle = new CellRendererToggle();
			col = new TreeViewColumn.with_attributes(_("Done"), cell_renderer_toggle, "active", Columns.DONE);
			col.set_sort_column_id(Columns.DONE);
			col.resizable = true;
			tv.append_column(col);

			return tv;
		}
	}
}
