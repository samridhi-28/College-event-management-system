<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="header.jspf" %>
<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>My registrations | Campus Events</title><link rel="stylesheet" href="css/style.css"></head>
<body>
<%@ include file="nav.jspf" %>
<section class="hero slim"><div class="wrap"><h1>My registrations</h1><p>Events you have signed up for.</p></div></section>
<main class="wrap">
  <% if (!flash.isEmpty()) { %><div class="alert"><%= flash %></div><% } %>
  <%
    boolean any = false;
    java.text.SimpleDateFormat fF = new java.text.SimpleDateFormat("EEE, d MMM yyyy");
    try (Connection c = DBUtil.getConnection()) {
      PreparedStatement ps = c.prepareStatement(
        "SELECT e.id,e.title,e.event_date,e.event_time,e.venue,e.image_url FROM registrations r " +
        "JOIN events e ON e.id=r.event_id WHERE r.user_id=? ORDER BY e.event_date");
      ps.setInt(1, uid);
      ResultSet rs = ps.executeQuery();
      while (rs.next()) { any = true;
        String time = rs.getString("event_time");
  %>
  <article class="item">
    <img src="<%= esc(imgSrc(rs.getString("image_url"), ctx)) %>" alt="">
    <div>
      <h3><%= esc(rs.getString("title")) %></h3>
      <p><%= fF.format(rs.getDate("event_date")) %><%= time == null ? "" : " at " + esc(time) %></p>
      <p><%= esc(rs.getString("venue")) %></p>
    </div>
    <form action="event" method="post" data-confirm="Cancel this registration?">
      <input type="hidden" name="action" value="leave"><input type="hidden" name="id" value="<%= rs.getInt("id") %>">
      <button class="btn ghost" type="submit">Cancel</button>
    </form>
  </article>
  <% } } catch (Exception e) { %><div class="alert error">Could not load registrations.</div><% } %>
  <% if (!any) { %><div class="empty">You have not registered for any events yet. <a href="events.jsp">Browse events</a></div><% } %>
</main>
<script src="js/script.js"></script>
</body></html>
