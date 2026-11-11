<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="header.jspf" %>
<% if (!"ADMIN".equals(role)) { response.sendRedirect("events.jsp"); return; } %>
<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Manage events | Campus Events</title><link rel="stylesheet" href="css/style.css"></head>
<body>
<%@ include file="nav.jspf" %>
<section class="hero slim"><div class="wrap"><h1>Manage events</h1><p>Add new events and keep the list up to date.</p></div></section>
<main class="wrap">
  <% if (!flash.isEmpty()) { %><div class="alert"><%= flash %></div><% } %>
  <%
    int nEvents = 0, nRegs = 0, nStudents = 0;
    try (Connection c = DBUtil.getConnection()) {
      ResultSet s = c.createStatement().executeQuery(
        "SELECT (SELECT COUNT(*) FROM events), (SELECT COUNT(*) FROM registrations), (SELECT COUNT(*) FROM users WHERE role='STUDENT')");
      if (s.next()) { nEvents = s.getInt(1); nRegs = s.getInt(2); nStudents = s.getInt(3); }
    } catch (Exception e) { }
  %>
  <div class="stats">
    <div><b><%= nEvents %></b>events</div>
    <div><b><%= nRegs %></b>registrations</div>
    <div><b><%= nStudents %></b>students</div>
  </div>

  <section class="panel">
    <h2>Add an event</h2>
    <form action="event" method="post">
      <input type="hidden" name="action" value="add">
      <div class="row">
        <div><label for="title">Title</label><input id="title" name="title" required></div>
        <div><label for="category">Category</label>
          <select id="category" name="category">
            <option>Technical</option><option>Cultural</option><option>Sports</option>
            <option>Arts</option><option>Career</option><option>Social</option><option>Workshop</option>
          </select></div>
      </div>
      <label for="description">Description</label><textarea id="description" name="description" rows="3"></textarea>
      <div class="row">
        <div><label for="venue">Venue</label><input id="venue" name="venue" required></div>
        <div><label for="organizer">Organizer</label><input id="organizer" name="organizer"></div>
      </div>
      <div class="row3">
        <div><label for="eventDate">Date</label><input id="eventDate" type="date" name="date" required></div>
        <div><label for="time">Time</label><input id="time" name="time" placeholder="10:00 AM"></div>
        <div><label for="capacity">Capacity</label><input id="capacity" type="number" name="capacity" min="1" value="100" required></div>
      </div>
      <label for="image">Poster image (optional)</label>
      <input id="image" name="image" placeholder="images/events/technova.svg or a full https:// link">
      <button class="btn" type="submit" style="margin-top:16px">Add event</button>
    </form>
  </section>

  <h2>All events</h2>
  <div class="table-wrap"><table>
    <tr><th></th><th>Title</th><th>Category</th><th>Date</th><th>Registered</th><th></th></tr>
  <%
    try (Connection c = DBUtil.getConnection()) {
      ResultSet rs = c.createStatement().executeQuery(
        "SELECT e.*, (SELECT COUNT(*) FROM registrations r WHERE r.event_id=e.id) AS taken " +
        "FROM events e ORDER BY e.event_date");
      while (rs.next()) { %>
    <tr>
      <td><img class="thumb" src="<%= esc(imgSrc(rs.getString("image_url"), ctx)) %>" alt=""></td>
      <td><%= esc(rs.getString("title")) %></td>
      <td><%= esc(rs.getString("category")) %></td>
      <td><%= rs.getDate("event_date") %></td>
      <td><%= rs.getInt("taken") %> / <%= rs.getInt("capacity") %></td>
      <td><form action="event" method="post" data-confirm="Delete this event and all its registrations?">
        <input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="<%= rs.getInt("id") %>">
        <button class="btn del" type="submit">Delete</button></form></td>
    </tr>
  <% } } catch (Exception e) { %><tr><td colspan="6">Could not load events.</td></tr><% } %>
  </table></div>
</main>
<script src="js/script.js"></script>
</body></html>
