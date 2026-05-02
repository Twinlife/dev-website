-----------------------------------------------------------------------
--  twinlife -- twinlife applications
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------
with Servlet.Filters.Dump;
with Servlet.Filters.Cache_Control;
with Servlet.Core.Files;
with Servlet.Core.Measures;
with Servlet.Security.Servlets;

with ASF.Servlets.Faces;
with ASF.Servlets.Ajax;
with ASF.Converters.Sizes;

with AWA.Users.Servlets;
with AWA.Users.Modules;
with AWA.Mail.Modules;
with AWA.Comments.Modules;
with AWA.Blogs.Modules;
with AWA.Tags.Modules;
with AWA.Storages.Modules;
with AWA.Applications;
with AWA.Workspaces.Modules;
with AWA.Services.Filters;
with AWA.Wikis.Modules;
with AWA.Wikis.Previews;
with AWA.Images.Modules;
with AWA.Jobs.Modules;
with AWA.SEO.Modules;
with AWA.Counters.Modules;
with AWA.Converters.Dates;
with Twinlife.Users.Modules;
package Twinlife.Applications is

   CONFIG_PATH  : constant String := "twinlife";
   CONTEXT_PATH : constant String := "";

   type Application is new AWA.Applications.Application with private;
   type Application_Access is access all Application'Class;

   --  Initialize the servlets provided by the application.
   --  This procedure is called by <b>Initialize</b>.
   --  It should register the application servlets.
   overriding
   procedure Initialize_Servlets (App : in out Application);

   --  Initialize the filters provided by the application.
   --  This procedure is called by <b>Initialize</b>.
   --  It should register the application filters.
   overriding
   procedure Initialize_Filters (App : in out Application);

   --  Initialize the AWA modules provided by the application.
   --  This procedure is called by <b>Initialize</b>.
   --  It should register the modules used by the application.
   overriding
   procedure Initialize_Modules (App : in out Application);

   --  Start the application.  This is called by the server container
   --  when the server is started.
   overriding
   procedure Start (App : in out Application);

private

   type Application is new AWA.Applications.Application with record
      Self               : Application_Access;

      --  Application servlets and filters (add new servlet and filter instances here).
      Faces              : aliased ASF.Servlets.Faces.Faces_Servlet;
      Ajax               : aliased ASF.Servlets.Ajax.Ajax_Servlet;
      Files              : aliased Servlet.Core.Files.File_Servlet;
      Dump               : aliased Servlet.Filters.Dump.Dump_Filter;
      Service_Filter     : aliased AWA.Services.Filters.Service_Filter;
      Measures           : aliased Servlet.Core.Measures.Measure_Servlet;
      No_Cache           : aliased Servlet.Filters.Cache_Control.Cache_Control_Filter;

      --  Authentication servlet and filter.
      Auth               : aliased Servlet.Security.Servlets.Request_Auth_Servlet;
      Verify_Auth        : aliased AWA.Users.Servlets.Verify_Auth_Servlet;

      --  Converters shared by web requests.
      Rel_Date_Converter : aliased AWA.Converters.Dates.Relative_Date_Converter;
      Size_Converter     : aliased ASF.Converters.Sizes.Size_Converter;

      --  The application modules.
      User_Module        : aliased AWA.Users.Modules.User_Module;
      Workspace_Module   : aliased AWA.Workspaces.Modules.Workspace_Module;
      Seo_Module         : aliased AWA.SEO.Modules.SEO_Module;
      Blog_Module        : aliased AWA.Blogs.Modules.Blog_Module;
      Mail_Module        : aliased AWA.Mail.Modules.Mail_Module;
      Comment_Module     : aliased AWA.Comments.Modules.Comment_Module;
      Storage_Module     : aliased AWA.Storages.Modules.Storage_Module;
      Tag_Module         : aliased AWA.Tags.Modules.Tag_Module;
      Job_Module         : aliased AWA.Jobs.Modules.Job_Module;
      Image_Module       : aliased AWA.Images.Modules.Image_Module;
      Wiki_Module        : aliased AWA.Wikis.Modules.Wiki_Module;
      Preview_Module     : aliased AWA.Wikis.Previews.Preview_Module;
      Counter_Module     : aliased AWA.Counters.Modules.Counter_Module;

      --  Add your modules here.
      Tw_User_Module     : aliased Twinlife.Users.Modules.User_Module;
   end record;

end Twinlife.Applications;
