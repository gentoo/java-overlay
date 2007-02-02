<div class="content">
	<p class="content_title">How to add a vhost and keep it running:</p>
	<ul>
		<li>   
			<p>First of all, create the profile with the helper:</p>
			<p class="file">Run:</p>
			<div class="code">
				jboss-4-bin-profiles-creator.sh create --profile=vhost1 
				--path=vhost1 --vhost=vhost1.yourdomain.com
			</div>
		</li>
		<li>    
			<p>Second, edit the tomcat file to add a vhost </p>
			<p>see: 
				<a href="http://wiki.jboss.org/wiki/Wiki.jsp?page=VirtualHosts">
					Jboss Wiki related page 
				</a>
			</p>
			<p>For example:</p>
			<p class="file"> tomcat server.xml</p>
			<div class="code">
				<p>&lt;Host name="vhost1.yourdomain.com"</p>
				<p>    autoDeploy="true" deployOnStartup="true" deployXML="true" /&gt;</p>
				<p>    &lt;Alias&gt;vhost1.yourdomain.com&lt;/Alias&gt;</p>
				<p>    &lt;Valve className="org.apache.catalina.valves.AccessLogValve"</p>
				<p>       prefix="vhost1.yourdomain.com-" suffix=".log"</p>
				<p> pattern="common" directory="${jboss.server.home.dir}/log"/&gt;</p>
				<p> &lt;/Host&gt;</p>
			</div>
		</li>
		<li>   
			<p>Third edit your webapp to be deploy on this vhost:</p>
			<p class="file"> WEB-INF/jboss-web.xml</p>
			<div class="code">
				<p>&lt;jboss-web&gt;</p>
				<p>&lt;virtual-host&gt;vhost1.yourdomain.com&lt;/virtual-host&gt;</p>
				<p>&lt;/jboss-web&gt;</p>
			</div>
		</li>
		<li>
				<p>Four, deploy your stuff in your "JBOSS DATA DIR" </p>
				<p>For example</p>
				<p class="code">/srv/vhost1.yourdomain.com/jboss-4/vhost1/deploy</p>
		</li>
	</ul>
</div>

