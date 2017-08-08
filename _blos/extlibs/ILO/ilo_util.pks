CREATE OR REPLACE PACKAGE Ilo_util AS
   ---------------------------------------------------------------------
   -- Provides several utility functions
   ---------------------------------------------------------------------
   --
   --  Instrumentation Library for Oracle
   --  Copyright (C) 2006 - 2008  Method R Corporation. All rights reserved.
   --
   --  This library is free software; you can redistribute it and/or
   --  modify it under the terms of the GNU Lesser General Public
   --  License as published by the Free Software Foundation; either
   --  version 2.1 of the License, or (at your option) any later version.
   --
   --  This library is distributed in the hope that it will be useful,
   --  but WITHOUT ANY WARRANTY; without even the implied warranty of
   --  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   --  Lesser General Public License for more details.
   --
   --  You should have received a copy of the GNU Lesser General Public
   --  License along with this library; if not, write to the Free Software
   --  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
   --
   ---------------------------------------------------------------------

   ---------------------------------------------------------------------
   --
   --  Naming Standards
   --    v_ <> Variables
   --    c_<>  Constants
   --    g_<>  Package Globals
   --    ex_   User defined Exceptions
   --    r_<>  Records
   --    cs_<> Cursors
   --    csp_<>   Cursor Parameters
   --    <>_T  Types
   --    <>_O  Object Types
   --

   -----------------------------------------------------------------------
   --< PUBLIC TYPES AND GLOBALS >-----------------------------------------
   -----------------------------------------------------------------------

   -----------------------------------------------------------------------
   --< PUBLIC METHODS >
   -----------------------------------------------------------------------

   ---------------------------------------------------------------------
   --< get_version >
   ---------------------------------------------------------------------
   --
   --  Purpose: Returns the version of the ILO_UTIL package
   --
   --   %return NUMBER	  NUMBER value that indicates version of ILO
   ---------------------------------------------------------------------
   FUNCTION get_version RETURN NUMBER;
   ---------------------------------------------------------------------
   
   ---------------------------------------------------------------------
   --< set_raise_exceptions >
   ---------------------------------------------------------------------
   --  Purpose: Normally, ILO will supress any exceptions raised during it's execution so that any instrumented application
   --  won't be adversely affected by an error that might occur while processing ILO. This flag actually tells ILO to raise
   --  any exceptions that it hits. This is probably most useful for testing purposes, but might have its advantages in a
   --  production environment.
   --
   --
   --   %param RAISE_EXCEPTIONS	  BOOLEAN Value that indicates whether ILO will riase exceptions (TRUE) or not (FALSE).
   --
   --   %usage_notes
   --   <li> The default for RAISE_EXCEPTIONS is FALSE.
   ---------------------------------------------------------------------
   PROCEDURE set_raise_exceptions(raise_exceptions boolean);
   ---------------------------------------------------------------------
   --< get_raise_exceptions >
   ---------------------------------------------------------------------
   --  Return the current value for RAISE_EXCEPTIONS. 
   --
   --   %param None
   --
   --   %return BOOLEAN
   --
   --   %usage_notes
   --   <li> Returns the value of RAISE_EXCEPTIONS set by the user. If the user has not called the SET_RAISE_EXCEPTIONS method, the default is FALSE.
   --
   ---------------------------------------------------------------------
   FUNCTION get_raise_exceptions RETURN boolean;
END Ilo_util;
