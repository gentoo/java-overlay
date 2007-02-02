<div class="content">

	<h2>Abstract</h2> 
	<p>In order to prevent you from the pain of creating a new jboss custom profile, we provide a simple helper wich can do a lot for you out of the box.</p>
	<p class="code">  /usr/bin/jboss-bin-4-profiles-creator.sh: action [ACTION_OPTIONS]</p>
	<p>  valid options are:</p>
	<ul>
		<li>delete</li>
      		<p>Delete a profile</p>
		<li>create</li>
		<p>Create a new profile</p>
		<li>help</li>
		<p>print this helper</p>
		<li>list</li>
		<p>List actual profiles</p>
	</ul>
	
	<p>Valid arguments are:</p>
	<ul>
		<li>--profile=serverdir_template</li>
       		<p>the name of the template to use to create the new profile with --create</p>
		<p>the name of the profile to delete with --delete</p>
               	<p>Default is 'gentoo'</p>
		<li>--path=/path/to/profile_to_create      SCOPE:create</li>
		<p>don't use the leading / for a subdir of /server</p>
		<p>indicate the full location to other wanted location</p>
		<li>--vhost=VHOST</p>
		<p>Set the vhost (default is 'localhost')</p>
		<p>Must exist a valid /srv/VHOST subdir</p>
 
	<p>TIPS:</p>
	<p> For create and delete, you must give the profile's name</p>
 
	<p>Examples</p>
	<p>/usr/bin/jboss-bin-4-profiles-creator.sh create --profile=gentoo --path=/opt/newprofile</p>
        <p>A new profile will be created in /opt/newprofile using default_vhost/gentoo as a template</p>
    	<p>A symlick in /srvdir/defaultvhost/jbossversion/newprofile will be done</p>
	<p>/usr/bin/jboss-bin-4-profiles-creator.sh create --profile=gentoo --path=newprofile</p>
	<p>A new profile will be created in default vhost using 
		srvdir/defaultvhost/jbossversion/igentoo as a template</p>
	<p>/usr/bin/jboss-bin-4-profiles-creator.sh --delete  --profile=gentoo
	<p>the 'gentoo' profile in default vhost will be deleted</p>
 
</div>
