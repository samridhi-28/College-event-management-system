package com.college.servlet;

import com.college.util.DBUtil;
import java.io.IOException;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if ("logout".equals(req.getParameter("action"))) {
            HttpSession s = req.getSession(false);
            if (s != null) s.invalidate();
        }
        res.sendRedirect("login.jsp");
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String action = req.getParameter("action");
        try (Connection c = DBUtil.getConnection()) {
            if ("register".equals(action)) {
                PreparedStatement ps = c.prepareStatement(
                    "INSERT INTO users(name,email,password) VALUES(?,?,?)");
                ps.setString(1, req.getParameter("name").trim());
                ps.setString(2, req.getParameter("email").trim().toLowerCase());
                ps.setString(3, DBUtil.sha256(req.getParameter("password")));
                ps.executeUpdate();
                res.sendRedirect("login.jsp?msg=Account created. Please log in.");
            } else { // login
                PreparedStatement ps = c.prepareStatement(
                    "SELECT id,name,role FROM users WHERE email=? AND password=?");
                ps.setString(1, req.getParameter("email").trim().toLowerCase());
                ps.setString(2, DBUtil.sha256(req.getParameter("password")));
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    HttpSession s = req.getSession();
                    s.setAttribute("userId", rs.getInt("id"));
                    s.setAttribute("userName", rs.getString("name"));
                    s.setAttribute("role", rs.getString("role"));
                    res.sendRedirect("ADMIN".equals(rs.getString("role")) ? "admin.jsp" : "events.jsp");
                } else {
                    res.sendRedirect("login.jsp?error=Incorrect email or password.");
                }
            }
        } catch (SQLException e) {
            if ("23505".equals(e.getSQLState())) {
                res.sendRedirect("register.jsp?error=That email is already registered.");
            } else {
                e.printStackTrace();
                res.sendRedirect("login.jsp?error=Something went wrong. Check the database connection.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            res.sendRedirect("login.jsp?error=Something went wrong. Check the database connection.");
        }
    }
}
