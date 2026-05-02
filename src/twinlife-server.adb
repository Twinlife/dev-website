-----------------------------------------------------------------------
--  Twinlife-server -- Application server
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------
with Util.Log.Loggers;
with Util.Commands;

with Servlet.Server.Web;

with AWA.Commands.Drivers;
with AWA.Commands.Start;
with AWA.Commands.Setup;
with AWA.Commands.Stop;
with AWA.Commands.List;
with AWA.Commands.Info;
with AWA.Commands.Migrate;
with AWA.Commands.User;
with AWA.Commands.Permission;
with AWA.Applications;

with Util.Http.Clients.Curl;
with ADO.Drivers;
--  with ADO.Sqlite;
--  with ADO.Mysql;
--  with ADO.Postgresql;

with Twinlife.Applications;
procedure Twinlife.Server is

   package Server_Commands is
     new AWA.Commands.Drivers (Driver_Name => "twinlife",
                               Container_Type => Servlet.Server.Web.AWS_Container);

   package List_Command is
     new AWA.Commands.List (Server_Commands);
   package Info_Command is
     new AWA.Commands.Info (Server_Commands);
   package Start_Command is
     new AWA.Commands.Start (Server_Commands);
   package Stop_Command is
     new AWA.Commands.Stop (Server_Commands);
   package Setup_Command is
     new AWA.Commands.Setup (Start_Command);
   package Migrate_Command is
     new AWA.Commands.Migrate (Server_Commands);
   package User_Command is
     new AWA.Commands.User (Server_Commands);
   package Permission_Command is
     new AWA.Commands.Permission (Server_Commands);

   pragma Unreferenced (Setup_Command, List_Command, Info_Command, Start_Command,
                        Stop_Command, Migrate_Command, User_Command, Permission_Command);
   Log       : constant Util.Log.Loggers.Logger := Util.Log.Loggers.Create ("Twinlife.Server");
   App       : constant Twinlife.Applications.Application_Access := new Twinlife.Applications.Application;
   WS        : Servlet.Server.Web.AWS_Container renames Server_Commands.WS;
   Context   : AWA.Commands.Context_Type;
   Arguments : Util.Commands.Dynamic_Argument_List;
begin
   --  Initialize the database drivers (all of them or specific ones).
   ADO.Drivers.Initialize;
   --  ADO.Sqlite.Initialize;
   --  ADO.Mysql.Initialize;
   --  ADO.Postgresql.Initialize;
   Util.Http.Clients.Curl.Register;
   Log.Info ("Connect you browser to: http://localhost:8080{0}/index.html",
             Twinlife.Applications.CONTEXT_PATH);
   App.Set_Config (AWA.Applications.P_Config_Name.P, Twinlife.Applications.CONFIG_PATH);
   WS.Register_Application (Twinlife.Applications.CONTEXT_PATH, App.all'Access);

   Server_Commands.Run (Context, Arguments);

exception
   when E : others =>
      AWA.Commands.Print (Context, E);
end Twinlife.Server;
