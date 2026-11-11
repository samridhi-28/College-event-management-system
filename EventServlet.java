package com.college.servlet;

import com.college.util.DBUtil;
import java.io.IOException;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/event")
public class EventServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) { res.sendRedirect("login.jsp"); return; }

        boolean admin = "ADMIN".equals(s.getAttribute("role"));
        int userId = (Integer) s.getAttribute("userId");
        String action = req.getParameter("action");
        String back = admin ? "admin.jsp" : "events.jsp";
        String msg = "";

        try (Connection c = DBUtil.getConnection()) {
            if ("add".equals(action) && admin) {
                PreparedStatement ps = c.prepareStatement(
                    "INSERT INTO events(title,description,venue,event_date,capacity,category,event_time,organizer,image_url) " +
                    "VALUES(?,?,?,?,?,?,?,?,?)");
                ps.setString(1, req.getParameter("title"));
                ps.setString(2, req.getParameter("description"));
                ps.setString(3, req.getParameter("venue"));
                ps.setDate(4, Date.valueOf(req.getParameter("date")));
                ps.setInt(5, Integer.parseInt(req.getParameter("capacity")));
                ps.setString(6, req.getParameter("category"));
                ps.setString(7, req.getParameter("time"));
                ps.setString(8, req.getParameter("organizer"));
                String img = req.getParameter("image");
                ps.setString(9, (img == null || img.trim().isEmpty()) ? "images/events/default.svg" : img.trim());
                ps.executeUpdate();
                msg = "Event added.";

            } else if ("delete".equals(action) && admin) {
                PreparedStatement ps = c.prepareStatement("DELETE FROM events WHERE id=?");
                ps.setInt(1, Integer.parseInt(req.getParameter("id")));
                ps.executeUpdate();
                msg = "Event deleted.";

            } else if ("join".equals(action)) {
                int eventId = Integer.parseInt(req.getParameter("id"));
                PreparedStatement chk = c.prepareStatement(
                    "SELECT capacity,(SELECT COUNT(*) FROM registrations WHERE event_id=?) AS taken " +
                    "FROM events WHERE id=?");
                chk.setInt(1, eventId); chk.setInt(2, eventId);
                ResultSet rs = chk.executeQuery();
                if (rs.next() && rs.getInt("taken") >= rs.getInt("capacity")) {
                    msg = "Sorry, this event is full.";
                } else {
                    PreparedStatement ps = c.prepareStatement(
                        "INSERT INTO registrations(user_id,event_id) VALUES(?,?)");
                    ps.setInt(1, userId); ps.setInt(2, eventId);
                    ps.executeUpdate();
                    msg = "You are registered.";
                }

            } else if ("leave".equals(action)) {
                PreparedStatement ps = c.prepareStatement(
                    "DELETE FROM registrations WHERE user_id=? AND event_id=?");
                ps.setInt(1, userId);
                ps.setInt(2, Integer.parseInt(req.getParameter("id")));
                ps.executeUpdate();
                msg = "Registration cancelled.";
            }
        } catch (SQLException e) {
            if ("23505".equals(e.getSQLState())) {
                msg = "You are already registered for this event.";
            } else {
                e.printStackTrace();
                msg = "Something went wrong.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            msg = "Something went wrong.";
        }
        res.sendRedirect(back + "?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
    }
}
