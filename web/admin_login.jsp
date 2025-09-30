<%@ page import="java.sql.*" %>
<%--
    This page handles the admin (rector) login process.
    It now validates credentials against the rector's ID, email, or mobile.
--%>

<%
    String errorMessage = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {

        // Get form parameters
        String loginCredential = request.getParameter("login_credential");
        String password = request.getParameter("password");

        // Database connection details
        String url = "jdbc:mysql://localhost:3306/hamp";
        String dbUsername = "root";
        String dbPassword = "root";
        String driver = "com.mysql.jdbc.Driver";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName(driver);
            conn = DriverManager.getConnection(url, dbUsername, dbPassword);

            //Check the login credential against rid, remail, and rmobile
            String sql = "SELECT rid, rname FROM rector WHERE (rid = ? OR remail = ? OR rmobile = ?) AND rpassword = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, loginCredential); // For rid
            pstmt.setString(2, loginCredential); // For remail
            pstmt.setString(3, loginCredential); // For rmobile
            pstmt.setString(4, password);         // For rpassword

            rs = pstmt.executeQuery();

            if (rs.next()) {
                session.setAttribute("admin_id", rs.getString("rid"));
                session.setAttribute("admin_name", rs.getString("rname"));
                response.sendRedirect("admin_dashboard.jsp");
                return;
            } else {
                errorMessage = "Invalid credentials. Please check your details and try again.";
            }

        } catch (Exception e) {
            errorMessage = "An error occurred. Please try again later.";
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Login</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937; --secondary-color: #f9fafb; --accent-color: #2563eb;
            --danger-color: #ef4444; --light-text-color: #6b7280; --card-bg: #ffffff;
            --border-color: #e5e7eb;
        }
        * { box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif; background: var(--secondary-color); margin: 0;
            display: flex; flex-direction: column; height: 100vh;
        }
        .top-panel {
            background: linear-gradient(135deg, var(--accent-color), #4f87ff); color: #ffffff;
            padding: 20px; text-align: center;
        }
        .top-panel h1 { margin: 0; font-size: 2.5em; }
        .navbar ul { list-style-type: none; margin: 15px 0 0; padding: 0; }
        .navbar li { display: inline-block; margin: 0 10px; }
        .navbar a {
            color: #ffffff; opacity: 0.9; text-decoration: none; font-size: 1.1em;
            padding: 8px 15px; border-radius: 5px; transition: all 0.3s ease;
        }
        .navbar a:hover { opacity: 1; background-color: rgba(255, 255, 255, 0.15); }
        /* --- CORRECTED DROPDOWN STYLES --- */
        .dropdown {
            position: relative;
            display: inline-block;
        }
        .dropdown .dropbtn {
            display: flex; /* Ensures caret is aligned */
            align-items: center;
            gap: 0.5rem; /* Space between text and icon */
            cursor: pointer;
            /* Inherits padding, color, etc. from .navbar a */
        }
        .dropdown-content {
            display: none;
            position: absolute;
            background-color: var(--card-bg);
            min-width: 180px;
            box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.1);
            z-index: 1;
            border-radius: 8px;
            /* Important fix: removed margin-top to prevent gap */
            top: 100%; /* Position right below the button */
            left: 0; /* Align left with the button */
            padding-top: 0.5rem; /* Visual space but still part of dropdown hover area */
            overflow: hidden;
        }
        .dropdown-content a {
            color: var(--primary-color);
            padding: 10px 16px; /* Adjusted padding for dropdown items */
            text-decoration: none;
            display: block;
            text-align: left;
            font-weight: 500;
            background-color: transparent;
            opacity: 1;
            white-space: nowrap; /* Prevent items from wrapping */
        }
        .dropdown-content a:hover {
            background-color: var(--secondary-color);
        }
        .dropdown:hover .dropdown-content {
            display: block;
        }
        .main-content {
            flex-grow: 1; display: flex; justify-content: center; align-items: center; padding: 20px;
        }
        .login-container {
            background-color: var(--card-bg); padding: 40px 50px; border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); width: 100%; max-width: 450px;
        }
        .login-container h2 {
            text-align: center; margin-top: 0; margin-bottom: 20px;
            color: var(--primary-color); font-size: 1.8em;
        }
        .error-message {
             background-color: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5;
             padding: 12px; border-radius: 6px; text-align: center; margin-bottom: 20px;
             font-size: 0.9em; font-weight: 500;
        }
        .login-container label {
            display: block; margin-bottom: 8px; font-weight: 600; color: var(--primary-color);
        }
        .login-container input[type="text"], .login-container input[type="password"] {
            width: 100%; padding: 12px; margin-bottom: 20px; border: 1px solid var(--border-color);
            border-radius: 6px; font-size: 1em;
        }
        .login-container input[type="submit"] {
            width: 100%; background-color: var(--accent-color); color: white; padding: 14px;
            border: none; border-radius: 6px; cursor: pointer; font-size: 16px;
            font-weight: 600; transition: background-color 0.3s ease;
        }
        .login-container input[type="submit"]:hover { background-color: #1e40af; }
        .footer {
            text-align: center; font-size: 13px; margin-top: 20px; color: var(--light-text-color);
        }
        .footer a { text-decoration: none; color: var(--accent-color); font-weight: 500; }
        .footer a:hover { text-decoration: underline; }
    </style>
</head>
<body>

    <header class="top-panel">
        <h1>Hostel Mate</h1>
        <nav class="navbar">
            <ul>
                <li><a href="index.html">Home</a></li>
                <li class="dropdown">
                    <a href="#" class="dropbtn">Login <i class="fas fa-caret-down fa-xs"></i></a>
                    <div class="dropdown-content">
                        <a href="user_login.jsp">Student</a>
                        <a href="admin_login.jsp">Admin</a>
                    </div>
                </li>
                <li><a href="home_hostels.jsp">Hostels</a></li>
                <li><a href="user_register.jsp">Apply</a></li>
                <li><a href="home_downloads.jsp">Downloads</a></li>
                <li><a href="index.html#contact">Contact Us</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="login-container">
            <h2>Admin Login</h2>
            
            <% if (errorMessage != null) { %>
                <div class="error-message">
                    <%= errorMessage %>
                </div>
            <% } %>

            <form action="admin_login.jsp" method="post">
                <%-- MODIFIED LABEL AND INPUT --%>
                <label for="login_credential">Rector ID / Email / Mobile:</label>
                <input type="text" id="login_credential" name="login_credential" placeholder="Enter your ID, Email, or Mobile" required>

                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>

                <input type="submit" value="Login">
            </form>
            <div class="footer">
                <a href="#">Forgot Password?</a>
            </div>
        </div>
    </main>
    
</body>
</html>