-----------------------------------------------------------------------
--  twinlife -- twinlife applications
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------

with Util.Log.Loggers;
with AWA.Events;
with AWA.Services.Contexts;
with Twinlife.Beans;
with Twinlife.Versions;
package body Twinlife.Applications is

   use AWA.Applications;

   Log     : constant Util.Log.Loggers.Logger := Util.Log.Loggers.Create ("Twinlife");

   --  ------------------------------
   --  Initialize the servlets provided by the application.
   --  This procedure is called by <b>Initialize</b>.
   --  It should register the application servlets.
   --  ------------------------------
   overriding
   procedure Initialize_Servlets (App : in out Application) is
   begin
      Log.Info ("Initializing application servlets...");

      App.Self := App'Unchecked_Access;
      AWA.Applications.Application (App).Initialize_Servlets;
      App.Add_Servlet (Name => "faces", Server => App.Self.Faces'Access);
      App.Add_Servlet (Name => "files", Server => App.Self.Files'Access);
      App.Add_Servlet (Name => "ajax", Server => App.Self.Ajax'Access);
      App.Add_Servlet (Name => "measures", Server => App.Self.Measures'Access);
      App.Add_Servlet (Name => "auth", Server => App.Self.Auth'Access);
      App.Add_Servlet (Name => "verify-auth", Server => App.Self.Verify_Auth'Access);
   end Initialize_Servlets;

   --  ------------------------------
   --  Initialize the filters provided by the application.
   --  This procedure is called by <b>Initialize</b>.
   --  It should register the application filters.
   --  ------------------------------
   overriding
   procedure Initialize_Filters (App : in out Application) is
   begin
      Log.Info ("Initializing application filters...");

      AWA.Applications.Application (App).Initialize_Filters;
      App.Add_Filter (Name => "dump", Filter => App.Self.Dump'Access);
      App.Add_Filter (Name => "measures", Filter => App.Self.Measures'Access);
      App.Add_Filter (Name => "service", Filter => App.Self.Service_Filter'Access);
      App.Add_Filter (Name => "no-cache", Filter => App.Self.No_Cache'Access);
      App.Set_Global ("contextPath", CONTEXT_PATH);
   end Initialize_Filters;

   --  ------------------------------
   --  Initialize the AWA modules provided by the application.
   --  This procedure is called by <b>Initialize</b>.
   --  It should register the modules used by the application.
   --  ------------------------------
   overriding
   procedure Initialize_Modules (App : in out Application) is
   begin
      Log.Info ("Initializing application modules...");

      App.Add_Converter (Name      => "smartDateConverter",
                         Converter => App.Self.Rel_Date_Converter'Access);
      App.Add_Converter (Name      => "sizeConverter",
                         Converter => App.Self.Size_Converter'Access);

      App.Register_Class (Name    => "Twinlife.Versions.Version_Bean",
                          Handler => Twinlife.Versions.Create_Version_Bean'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Users.Modules.NAME,
                URI    => "user",
                Module => App.User_Module'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Workspaces.Modules.NAME,
                URI    => "workspaces",
                Module => App.Workspace_Module'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.SEO.Modules.NAME,
                URI    => "sitemaps",
                Module => App.Seo_Module'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Mail.Modules.NAME,
                URI    => "mail",
                Module => App.Mail_Module'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Comments.Modules.NAME,
                URI    => "comments",
                Module => App.Comment_Module'Access);

      --  Define our specific comment creation bean.
      AWA.Comments.Modules.Register.Register
        (Plugin => App.Comment_Module,
         Name   => "Twinlife.Beans.Comment_Bean",
         Handler => Twinlife.Beans.Create_Comment_Bean'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Tags.Modules.NAME,
                URI    => "tags",
                Module => App.Tag_Module'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Jobs.Modules.NAME,
                URI    => "jobs",
                Module => App.Job_Module'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Storages.Modules.NAME,
                URI    => "storages",
                Module => App.Storage_Module'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Images.Modules.NAME,
                URI    => "images",
                Module => App.Image_Module'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Counters.Modules.NAME,
                URI    => "counters",
                Module => App.Counter_Module'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Blogs.Modules.NAME,
                URI    => "blogs",
                Module => App.Blog_Module'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Wikis.Modules.NAME,
                URI    => "wikis",
                Module => App.Wiki_Module'Access);

      Register (App    => App.Self.all'Access,
                Name   => AWA.Wikis.Previews.NAME,
                URI    => "wikis-preview",
                Module => App.Preview_Module'Access);
      Register (App    => App.Self.all'Access,
                Name   => Twinlife.Users.Modules.NAME,
                URI    => "twusers",
                Module => App.Tw_User_Module'Access);
   end Initialize_Modules;

   --  Start the application.  This is called by the server container
   --  when the server is started.
   overriding
   procedure Start (App : in out Application) is
   begin
      AWA.Applications.Application (App).Start;

      declare
         Context       : aliased AWA.Services.Contexts.Service_Context;
         Refresh_Event : AWA.Events.Module_Event;
      begin
         --  Setup the service context.
         Context.Set_Context (App'Unchecked_Access, null);
         Refresh_Event.Set_Event_Kind (Twinlife.Versions.Event_Refresh.Kind);
         App.Send_Event (Refresh_Event);
      end;
   end Start;

end Twinlife.Applications;
