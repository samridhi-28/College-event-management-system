<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="header.jspf" %>
<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Events | Campus Events</title><link rel="stylesheet" href="css/style.css"></head>
<body>
<%@ include file="nav.jspf" %>
<section class="hero"><div class="wrap">
  <h1>What is happening on campus</h1>
  <p>Pick an event and register in one click. Seats are counted live.</p>
  <input id="search" type="search" placeholder="Search by title, venue or organizer" aria-label="Search events">
</div></section>
<main class="wrap">
  <% if (!flash.isEmpty()) { %><div class="alert"><%= flash %></div><% } %>
  <div id="chips" class="chips" aria-label="Filter by category"></div>
  <div class="grid">
  <%
    boolean any = false;
    java.text.SimpleDateFormat dF = new java.text.SimpleDateFormat("dd"),
        mF = new java.text.SimpleDateFormat("MMM"), fF = new java.text.SimpleDateFormat("EEE, d MMM yyyy");
    try (Connection c = DBUtil.getConnection()) {
      PreparedStatement ps = c.prepareStatement(
        "SELECT e.*, (SELECT COUNT(*) FROM registrations r WHERE r.event_id=e.id) AS taken, " +
        "(SELECT COUNT(*) FROM registrations r WHERE r.event_id=e.id AND r.user_id=?) AS mine " +
        "FROM events e WHERE e.event_date >= CURRENT_DATE ORDER BY e.event_date");
      ps.setInt(1, uid);
      ResultSet rs = ps.executeQuery();
      while (rs.next()) {
        any = true;
        int cap = rs.getInt("capacity"), taken = rs.getInt("taken"), left = cap - taken;
        int pct = cap > 0 ? Math.min(100, taken * 100 / cap) : 100;
        java.sql.Date d = rs.getDate("event_date");
        String cat = rs.getString("category");
        if (cat == null || cat.isEmpty()) cat = "General";
        String title = esc(rs.getString("title"));
        String time = rs.getString("event_time");
        String org = rs.getString("organizer");
  %>
    <article class="card" data-category="<%= esc(cat) %>">
      <div class="poster">
        <img src="<%= esc(imgSrc(rs.getString("image_url"), ctx)) %>" alt="<%= title %> poster" loading="lazy">
        <div class="stub"><b><%= dF.format(d) %></b><span><%= mF.format(d) %></span></div>
        <span class="tag"><%= esc(cat) %></span>
      </div>
      <div class="body">
        <h3><%= title %></h3>
        <dl class="facts">
          <dt>When</dt><dd><%= fF.format(d) %><%= time == null ? "" : " at " + esc(time) %></dd>
          <dt>Where</dt><dd><%= esc(rs.getString("venue")) %></dd>
          <% if (org != null && !org.isEmpty()) { %><dt>By</dt><dd><%= esc(org) %></dd><% } %>
        </dl>
        <p class="desc"><%= esc(rs.getString("description")) %></p>
        <div class="bar" title="<%= taken %> of <%= cap %> seats taken"><i style="width:<%= pct %>%"></i></div>
        <div class="seats"><%= left > 0 ? left + " of " + cap + " seats left" : "Event is full" %></div>
        <form action="event" method="post">
          <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
          <% if (rs.getInt("mine") > 0) { %>
            <input type="hidden" name="action" value="leave">
            <button class="btn ghost block" type="submit">Cancel registration</button>
          <% } else if (left > 0) { %>
            <input type="hidden" name="action" value="join">
            <button class="btn go block" type="submit">Register</button>
          <% } else { %>
            <button class="btn ghost block" type="button" disabled>Full</button>
          <% } %>
        </form>
      </div>
    </article>
  <% } } catch (Exception e) { %><div class="alert error">Could not load events. Check the database connection and run update_events.sql.</div><% } %>
  </div>
  <% if (!any) { %><div class="empty">No upcoming events yet. Check back soon.</div><% } %>
</main>
<script src="js/script.js"></script>
</body></html>
