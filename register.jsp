<%@ page contentType="text/html;charset=UTF-8" %>
<% String err = request.getParameter("error");
   if (err != null) err = err.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;"); %>
<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Create account | Campus Events</title><link rel="stylesheet" href="css/style.css"></head>
<body class="auth-page">
<section class="auth-art">
  <a class="brand" href="login.jsp"><span class="logo"></span>Campus Events</a>
  <div>
    <h1>Join in. Your next event is waiting.</h1>
    <p>Create a free student account to register for fests, workshops and more.</p>
  </div>
</section>
<section class="auth-form"><div class="box">
  <h2>Create your account</h2>
  <p class="sub">It takes less than a minute.</p>
  <% if (err != null) { %><div class="alert error"><%= err %></div><% } %>
  <form id="registerForm" action="auth" method="post">
    <input type="hidden" name="action" value="register">
    <label for="name">Full name</label><input id="name" name="name" required>
    <label for="email">Email</label><input id="email" type="email" name="email" required>
    <label for="password">Password (6+ characters)</label><input id="password" type="password" name="password" required>
    <label for="confirm">Confirm password</label><input id="confirm" type="password" name="confirm" required>
    <button class="btn block" type="submit">Create account</button>
  </form>
  <p class="alt">Already registered? <a href="login.jsp">Log in</a></p>
</div></section>
<script src="js/script.js"></script>
</body></html>
