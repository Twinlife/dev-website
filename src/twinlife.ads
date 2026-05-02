-----------------------------------------------------------------------
--  twinlife --
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------
with Ada.Strings.Unbounded;
package Twinlife is

   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

   function To_String (S : in UString) return String
     renames Ada.Strings.Unbounded.To_String;

   function To_UString (S : in String) return UString
     renames Ada.Strings.Unbounded.To_Unbounded_String;

   function Length (S : in UString) return Natural
     renames Ada.Strings.Unbounded.Length;

end Twinlife;
