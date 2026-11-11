<%@ page contentType="text/html;charset=UTF-8" %>
<%
  String err = request.getParameter("error"), msg = request.getParameter("msg");
  if (err != null) err = err.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
  if (msg != null) msg = msg.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
%>
<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Log in | Campus Events</title><link rel="stylesheet" href="css/style.css"></head>
<body class="auth-page">
<section class="auth-art">
  <a class="brand" href="login.jsp"><span class="logo"></span>Campus Events</a>
  <div>
    <h1>Every campus event, in one place.</h1>
    <p>Find what is on, register in one click and keep track of your seats.</p>
  </div>
</section>
<section class="auth-form"><div class="box">
  <h2>Welcome back</h2>
  <p class="sub">Log in to browse and register for events.</p>
  <% if (err != null) { %><div class="alert error"><%= err %></div><% } %>
  <% if (msg != null) { %><div class="alert"><%= msg %></div><% } %>
  <form action="auth" method="post">
    <input type="hidden" name="action" value="login">
    <label for="email">Email</label><input id="email" type="email" name="email" required>
    <label for="password">Password</label><input id="password" type="password" name="password" required>
    <button class="btn block" type="submit">Log in</button>
  </form>
  <p class="alt">New student? <a href="register.jsp">Create an account</a></p>
</div></section>
<script src="js/script.js"></script>
</body></html>
