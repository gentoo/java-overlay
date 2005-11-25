package org.gudy.azureus2.update;
/*
 * Created on 31-May-2004
 * Created by Paul Gardner
 * Copyright (C) 2004 Aelitis, All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 * 
 * AELITIS, SARL au capital de 30,000 euros
 * 8 Allee Lenotre, La Grille Royale, 78600 Le Mesnil le Roi, France.
 *
 */

/**
 * @author parg
 *
 */

import java.io.File;
import java.util.Properties;

import org.gudy.azureus2.plugins.*;

public class 
UpdaterPatcher
	implements UnloadablePlugin
{
	public void
	initialize(
		PluginInterface	pi )
	{
		Properties	props = pi.getPluginProperties();
		
		props.setProperty( "plugin.mandatory", "true" );

		try{
			String	library_path = System.getProperty( "java.library.path");
			String	old_path	= library_path;
						
		    if ( library_path != null ){
		    	
		    		// remove any quotes from the damn thing
		    	
		    	boolean	changed = false;
		    	
		    	String	temp = "";
		    	
		    	for (int i=0;i<library_path.length();i++){
		    		
		    		char	c = library_path.charAt(i);
		    		
		    		if ( c != '"' ){
		    			
		    			temp += c;
		    			
		    		}else{
		    			
		    			changed	= true;
		    		}
		    	}
		    	
		    	library_path	= temp;
		    	
		    		// remove trailing separator chars if they exist as they stuff up
		    		// the following "
		    	
		    	while( library_path.endsWith(File.separator)){
		    	
		    		changed = true;
		    		
		    		library_path = library_path.substring( 0, library_path.length()-1 );
		    	}
		    	
		    	if ( changed ){
		    		
		    		System.out.println( "UpdaterPatcher: Fixing library path: old = " + old_path + ", new = " + library_path );
		    		
		    		System.setProperty( "java.library.path", library_path );
		    	}
		    }
		}catch( Throwable e ){
		    	
		   	e.printStackTrace();
		}
	}
	
	public void
	unload()
	{
	}
}
