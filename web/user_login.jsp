<%@ page import="java.sql.*" %>

<%-- 
    This scriptlet contains the backend logic to handle the student login process.
    It runs only when the user submits the login form via the POST method.
--%>
<%
    String errorMessage = null; // Variable to hold a potential error message

    // Check if the form has been submitted
    if ("POST".equalsIgnoreCase(request.getMethod())) {

        // Get form parameters
        String rollNo = request.getParameter("roll_no");
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

            // Create a secure query to find the user by roll_no and password
            // IMPORTANT: Storing plain text passwords is a major security risk. 
            // In a real-world application, you should hash passwords during registration
            // and compare the hash here.
            String sql = "SELECT * FROM student_auth WHERE roll_no = ? AND password = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, rollNo);
            pstmt.setString(2, password);

            rs = pstmt.executeQuery();

            // If rs.next() is true, a matching user was found
            if (rs.next()) {
                // --- LOGIN SUCCESSFUL ---
                // Create a session for the user
                session.setAttribute("user_roll_no", rollNo); // Store roll number in session
                session.setAttribute("user_fullname", rs.getString("fullname")); // Store full name
                
                // Redirect to the user's dashboard
                response.sendRedirect("user_dashboard.jsp");
                return; // Stop further execution of the JSP page
            } else {
                // --- LOGIN FAILED ---
                // Set an error message to be displayed on the page
                errorMessage = "Invalid Roll Number or Password. Please try again.";
            }

        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "An error occurred. Please contact support.";
        } finally {
            // Close all database resources to prevent leaks
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #1f2937;
            --secondary-color: #f9fafb;
            --accent-color: #2563eb;
            --light-text-color: #6b7280;
            --card-bg: #ffffff;
            --border-color: #e5e7eb;
            --danger-color: #ef4444;
        }
        * {
            box-sizing: border-box;
        }
        body {
            margin: 0;
            font-family: 'Inter', sans-serif;
            display: grid;
            grid-template-columns: 1fr; 
            grid-template-rows: auto 1fr;
            grid-template-areas:
                "header"
                "main";
            height: 100vh;
            background-color: var(--secondary-color);
        }
        .top-panel {
            grid-area: header;
            background: linear-gradient(135deg, var(--accent-color), #4f87ff);
            color: #ffffff;
            padding: 20px;
            text-align: center;
        }
        .top-panel h1 {
            margin: 0;
            font-size: 2.5em;
        }
        .navbar ul {
            list-style-type: none;
            margin: 15px 0 0;
            padding: 0;
        }
        .navbar li {
            display: inline-block;
            margin: 0 10px;
        }
        .navbar a {
            color: #ffffff;
            opacity: 0.9;
            text-decoration: none;
            font-size: 1.1em;
            padding: 8px 15px;
            border-radius: 5px;
            transition: all 0.3s ease;
        }
        .navbar a:hover {
            opacity: 1;
            background-color: rgba(255, 255, 255, 0.15);
        }
        .dropdown {
            position: relative;
            display: inline-block;
        }
        .dropdown .dropbtn {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            cursor: pointer;
        }
        .dropdown-content {
            display: none;
            position: absolute;
            background-color: var(--card-bg);
            min-width: 200px;
            box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.1);
            z-index: 1;
            border-radius: 8px;
            margin-top: 10px;
            overflow: hidden;
        }
        .dropdown-content a {
            color: var(--primary-color);
            padding: 12px 16px;
            text-decoration: none;
            display: block;
            text-align: left;
            font-weight: 500;
            background-color: transparent;
            opacity: 1;
        }
        .dropdown-content a:hover {
            background-color: var(--secondary-color);
        }
        .dropdown:hover .dropdown-content {
            display: block;
        }
        .main-content {
            grid-area: main;
            padding: 25px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .auth-wrapper {
            display: flex;
            align-items: center;
            background-color: var(--card-bg);
            padding: 20px 40px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            max-width: 800px;
        }
        .login-container {
            width: 350px;
            padding: 20px;
        }
        .login-container h2 {
            text-align: center;
            margin-top: 0;
            margin-bottom: 20px;
            color: var(--primary-color);
        }
        .login-container label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--primary-color);
        }
        .login-container input[type="text"],
        .login-container input[type="password"] {
            width: 100%;
            padding: 12px;
            margin-bottom: 18px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 1em;
        }
        .login-container input[type="submit"] {
            width: 100%;
            background-color: var(--accent-color);
            color: white;
            padding: 12px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }
        .login-container input[type="submit"]:hover {
            background-color: #1e40af;
        }
        .footer {
            text-align: center;
            font-size: 13px;
            margin-top: 15px;
            color: var(--light-text-color);
        }
        .footer a {
            text-decoration: none;
            color: var(--accent-color);
            font-weight: 500;
        }
        .footer a:hover {
            text-decoration: underline;
        }
        .error-message {
            color: var(--danger-color);
            background-color: #fee2e2;
            border: 1px solid #fca5a5;
            padding: 10px;
            border-radius: 6px;
            text-align: center;
            margin-bottom: 15px;
            font-size: 0.9em;
        }
        .divider {
            height: 250px;
            border-left: 1px solid var(--border-color);
            position: relative;
            margin: 0 40px;
        }
        .divider .or-circle {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            color: var(--light-text-color);
            width: 45px;
            height: 45px;
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            font-weight: bold;
        }
        .register-section {
            width: 350px;
            padding: 20px;
            text-align: center;
        }
        .register-section h2 {
            margin-top: 0;
            margin-bottom: 25px;
            color: var(--primary-color);
        }
        .register-section p {
            font-size: 1.1em;
            color: var(--light-text-color);
            margin-bottom: 30px;
        }
        .register-section a.register-button {
            display: inline-block;
            background-color: #28a745;
            color: white;
            padding: 14px 25px;
            text-decoration: none;
            border-radius: 6px;
            font-size: 18px;
            font-weight: bold;
            transition: background-color 0.3s ease;
        }
        .register-section a.register-button:hover {
            background-color: #218838;
        }
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
                <li><a href="home_notices.jsp">Downloads</a></li>
                <li><a href="#">Contact Us</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="auth-wrapper">

            <div class="login-container">
                <h2>Student Login</h2>

                <%-- This block will display the error message if login fails --%>
                <%
                    if (errorMessage != null) {
                %>
                    <div class="error-message"><%= errorMessage %></div>
                <%
                    }
                %>

                <%-- MODIFIED: Form now submits to this page and uses 'roll_no' --%>
                <form action="user_login.jsp" method="post">
                    <label for="roll_no">Roll Number:</label>
                    <input type="text" id="roll_no" name="roll_no" required>
                    
                    <label for="password">Password:</label>
                    <input type="password" id="password" name="password" required>
                    
                    <input type="submit" value="Login">
                </form>
                <div class="footer">
                    <a href="forgot_password.jsp">Forgot Password?</a>
                </div>
            </div>

            <div class="divider">
                <div class="or-circle">OR</div>
            </div>

            <div class="register-section">
                <h2>New User?</h2>
                <p>Click the button below to create a new account.</p>
                <a href="user_register.jsp" class="register-button">Register Now</a>
            </div>

        </div>
    </main>

</body>
</html>