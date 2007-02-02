<div class="content">
	<div class="content_title">Abstract</div> 
	<p>In order to prevent you from the pain of creating a new jboss custom profile, 
	   we provide a simple helper wich can do a lot for you out of the box.</p>
	<div class="code">/usr/bin/jboss-4-profiles-creator.sh command   [argument] [argument] ...</div>

	<div class="helper_title">Commands :
		<div class="helper_args">delete</div>
		<div class="helper_desc">Delete a profile</div>
		<div class="helper_args">create</div>
		<div class="helper_desc">Create a new profile</div>
		<div class="helper_args">help</div>
		<div class="helper_desc">print this helper</div>
		<div class="helper_args">list</div>
		<div class="helper_desc">list actual profiles</div>
	</div>
	<div class="helper_title">Arguments :
		<div class="helper_args">--profile=serverdir_template</div>
		<div class="helper_desc">The name of the template to use to create the new profile with <code>create</code></div>
		<div class="helper_desc">The name of the profile to delete with <code>delete</code></div>
		<div class="helper_desc">Default is 'gentoo'</div>
		<div class="helper_args">--path=/path/to/profile_to_create      SCOPE:create</div>
		<div class="helper_desc">Don't use the leading / for a subdir of /server</div>
		<div class="helper_desc">Indicate the full location to other wanted location</div>
		<div class="helper_args">--vhost=VHOST</div>
		<div class="helper_desc" >Set the vhost (default is 'localhost')</div>
		<div class="helper_desc">Must exist a valid /srv/VHOST subdir</div>
	</div>
	<div class="helper_title">Tips :
		<div class="helper_args"> For <code>create</code> and <code>delete</code>, you must give the profile's name</div>
	</div>
	<div class="helper_title">Examples :
		<div class="helper_args">/usr/bin/jboss-4-profiles-creator.sh create --profile=gentoo --path=/opt/newprofile</div>
		<div class="helper_desc">A symlink in /srvdir/defaultvhost/jbossversion/newprofile will be done</div>
		<div class="helper_args">/usr/bin/jboss-4-profiles-creator.sh create --profile=gentoo --path=newprofile</div> 
		<div class="helper_desc">A new profile will be created in default vhost using srvdir/defaultvhost/jbossversion/igentoo as a template</div>
		<div class="helper_args">/usr/bin/jboss-4-profiles-creator.sh delete  --profile=gentoo</div>
		<div class="helper_desc">The 'gentoo' profile in default vhost will be deleted</div>
	</div>
</div>
