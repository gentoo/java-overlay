<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<title>gentoo rox</title>
	 <link rel="stylesheet" type="text/css"  href="css/styles.css" />
</head>
<body>
	<jsp:include page="./template/header.jsp" />
	<div class="body_c">
		<jsp:include page="./template/menu.jsp" />
		<% if (request.getParameter("page") == null){ %>
			<%@ include   file="./modules/main.jsp" %>
		<% }  %>
		<% if ("vhost".equals(request.getParameter("page"))){ %>
			<%@  include  file="./modules/vhost.jsp" %>
		<% } %>		
		<% if ("profile_manager".equals(request.getParameter("page"))){ %>
			<%@  include  file="./modules/profile_manager.jsp" %>
		<% } %>		

		<div class="spacer">&nbsp;</div>
	</div>
	<jsp:include page="./template/footer.jsp" />
</body>
</html>
