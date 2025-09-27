<%@ page import="java.sql.*" %>
<%--
    This page handles new student registration. It now uses a pop-up modal
    to display success, failure, or "already registered" messages to the user
    instead of redirecting or showing an error page.
--%>

<%
    // --- JSP LOGIC SECTION ---
    String message = null;
    String messageType = ""; // "success" or "error"

    if ("POST".equalsIgnoreCase(request.getMethod())) {

        // Database connection details
        String url = "jdbc:mysql://localhost:3306/hamp"; // Using your 'hamp' database
        String dbUsername = "root"; 
        String dbPassword = "root"; 
        String driver = "com.mysql.jdbc.Driver"; // Modern driver class name

        // Get form parameters
        String firstName = request.getParameter("first_name");
        String lastName = request.getParameter("last_name");
        String rollNo = request.getParameter("roll_no");
        String email = request.getParameter("email");
        String mobile = request.getParameter("phone"); 
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("cpassword");

        String fullname = firstName + " " + lastName;

        Connection conn = null;
        PreparedStatement checkPstmt = null;
        PreparedStatement insertPstmt = null;
        ResultSet rs = null;

        if (password == null || !password.equals(confirmPassword)) {
            message = "Passwords do not match. Please try again.";
            messageType = "error";
        } else {
            try {
                Class.forName(driver);
                conn = DriverManager.getConnection(url, dbUsername, dbPassword);

                // Step 1: Explicitly check ONLY for a duplicate Roll Number
                String checkSql = "SELECT roll_no FROM student_auth WHERE roll_no = ?";
                checkPstmt = conn.prepareStatement(checkSql);
                checkPstmt.setString(1, rollNo);
                rs = checkPstmt.executeQuery();

                if (rs.next()) {
                    // This condition is ONLY met if the Roll Number already exists.
                    message = "A user with this Roll Number already exists. Please log in.";
                    messageType = "error";
                } else {
                    // Step 2: If Roll Number is unique, proceed with the insertion.
                    String plainTextPassword = password;
                    
                    String sql = "INSERT INTO student_auth (roll_no, fullname, email, mobile, password) VALUES (?, ?, ?, ?, ?)";
                    insertPstmt = conn.prepareStatement(sql);
                    
                    insertPstmt.setString(1, rollNo);
                    insertPstmt.setString(2, fullname);
                    insertPstmt.setString(3, email);
                    insertPstmt.setString(4, mobile);
                    insertPstmt.setString(5, plainTextPassword);

                    int rowsAffected = insertPstmt.executeUpdate();

                    if (rowsAffected > 0) {
                        message = "Registration Successful! You can now log in.";
                        messageType = "success";
                    } else {
                        message = "Registration failed unexpectedly. Please contact support.";
                        messageType = "error";
                    }
                }

            } catch (SQLIntegrityConstraintViolationException e) {
                // This catch block will now only handle other integrity issues (e.g., a duplicate email).
                // The message is generic, as requested.
                message = "Registration failed due to a data conflict. Please check your details.";
                messageType = "error";
                e.printStackTrace();
            } catch (Exception e) {
                message = "An error occurred. Please check your details or contact support.";
                messageType = "error";
                e.printStackTrace();
            } finally {
                // Close all resources
                try { if (rs != null) rs.close(); } catch (Exception e) {}
                try { if (checkPstmt != null) checkPstmt.close(); } catch (Exception e) {}
                try { if (insertPstmt != null) insertPstmt.close(); } catch (Exception e) {}
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Registration</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937;
            --secondary-color: #f9fafb;
            --accent-color: #2563eb;
            --light-text-color: #6b7280;
            --card-bg: #ffffff;
            --border-color: #e5e7eb;
            --success-color: #10b981;
            --danger-color: #ef4444;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: 'Inter', sans-serif;
            display: grid;
            grid-template-columns: 1fr; 
            grid-template-rows: auto 1fr;
            grid-template-areas: "header" "main";
            height: 100vh;
            background: var(--secondary-color);
        }
        .top-panel {
            grid-area: header;
            background: linear-gradient(135deg, var(--accent-color), #4f87ff);
            color: #ffffff;
            padding: 20px;
            text-align: center;
        }
        .top-panel h1 { margin: 0; font-size: 2.5em; }
        .navbar ul { list-style-type: none; margin: 15px 0 0; padding: 0; }
        .navbar li { display: inline-block; margin: 0 10px; }
        .navbar a {
            color: #ffffff;
            opacity: 0.9;
            text-decoration: none;
            font-size: 1.1em;
            padding: 8px 15px;
            border-radius: 5px;
            transition: all 0.3s ease;
        }
        .navbar a:hover { opacity: 1; background-color: rgba(255, 255, 255, 0.15); }
        .dropdown { position: relative; display: inline-block; }
        .dropdown .dropbtn { display: flex; align-items: center; gap: 0.5rem; cursor: pointer; }
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
            color: var(--primary-color); padding: 12px 16px; text-decoration: none;
            display: block; text-align: left; font-weight: 500;
            background-color: transparent; opacity: 1;
        }
        .dropdown-content a:hover { background-color: var(--secondary-color); }
        .dropdown:hover .dropdown-content { display: block; }
        .main-content {
            grid-area: main;
            padding: 40px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow-y: auto;
        }
        .auth-wrapper {
            display: flex;
            align-items: center;
            background-color: var(--card-bg);
            padding: 20px 40px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 900px;
        }
        .register-form-container { width: 100%; padding: 20px; }
        .register-form-container h2 { text-align: center; margin-top: 0; margin-bottom: 25px; color: var(--primary-color); }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: var(--primary-color); }
        .form-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 1em;
        }
        .name-row { display: flex; gap: 15px; }
        .password-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        .submit-btn {
            width: 100%;
            background-color: var(--accent-color);
            color: white;
            padding: 14px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1.1em;
            font-weight: bold;
            margin-top: 10px;
            transition: background-color 0.3s ease;
        }
        .submit-btn:hover { background-color: #1e40af; }
        .divider {
            height: 350px;
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
        .login-prompt-section { width: 100%; max-width: 300px; padding: 20px; text-align: center; }
        .login-prompt-section h2 { margin-top: 0; margin-bottom: 25px; color: var(--primary-color); }
        .login-prompt-section p { font-size: 1.1em; color: var(--light-text-color); margin-bottom: 30px; }
        .login-prompt-section a.login-button {
            display: inline-block;
            background-color: var(--accent-color);
            color: white;
            padding: 14px 25px;
            text-decoration: none;
            border-radius: 6px;
            font-size: 18px;
            font-weight: bold;
            transition: background-color 0.3s ease;
        }
        .login-prompt-section a.login-button:hover { background-color: #1e40af; }
        
        /* --- POP-UP MODAL STYLES --- */
        .modal-overlay {
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background-color: rgba(0,0,0,0.5);
            display: none; /* Initially hidden */
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        .modal-box {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            width: 90%;
            max-width: 400px;
            text-align: center;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .modal-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        .modal-icon.success { color: var(--success-color); }
        .modal-icon.error { color: var(--danger-color); }
        .modal-box h3 { font-size: 1.5rem; margin: 0 0 0.5rem; }
        .modal-box p { color: var(--light-text-color); margin: 0 0 1.5rem; }
        .modal-button {
            display: block;
            width: 100%;
            padding: 0.8rem;
            border-radius: 8px;
            border: none;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
        }
        .modal-button.success { background-color: var(--success-color); color: white; }
        .modal-button.error { background-color: var(--danger-color); color: white; }
        
        @media (max-width: 992px) {
            .auth-wrapper { flex-direction: column; max-width: 500px; }
            .divider { height: auto; width: 80%; border-left: none; border-top: 1px solid var(--border-color); margin: 30px 0; }
        }
        @media (max-width: 480px) {
            .name-row, .password-row { flex-direction: column; grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <header class="top-panel">
        <h1>HOSTEL MATE</h1>
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
                <li><a href="index.html#contact">Contact Us</a></li>
            </ul>
        </nav>
    </header>
    <main class="main-content">
        <div class="auth-wrapper">
            <div class="register-form-container">
                <h2>Create an Account</h2>
                <form action="user_register.jsp" method="post">
                    <div class="form-group">
                        <label>Full Name:</label>
                        <div class="name-row">
                            <input type="text" name="first_name" placeholder="First Name" required>
                            <input type="text" name="last_name" placeholder="Last Name" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="roll_no">Roll Number:</label>
                        <input type="text" id="roll_no" name="roll_no" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email ID:</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                    <div class="form-group">
                        <label for="phone">Phone Number:</label>
                        <input type="tel" id="phone" name="phone" placeholder="10-digit number" pattern="[0-9]{10}" maxlength="10" required>
                    </div>
                    <div class="form-group password-row">
                        <div>
                           <label for="password">Password:</label>
                           <input type="password" id="password" name="password" required>
                        </div>
                        <div>
                           <label for="cpassword">Confirm Password:</label>
                           <input type="password" id="cpassword" name="cpassword" required>
                        </div>
                    </div>
                    <button type="submit" class="submit-btn">Register</button>
                </form>
            </div>
            <div class="divider">
                <div class="or-circle">OR</div>
            </div>
            <div class="login-prompt-section">
                <h2>Already Registered?</h2>
                <p>If you have an account, just log in.</p>
                <a href="user_login.jsp" class="login-button">Login Now</a>
            </div>
        </div>
    </main>

    <div class="modal-overlay" id="popup-modal">
        <div class="modal-box">
            <div id="modal-icon" class="modal-icon"></div>
            <h3 id="modal-title"></h3>
            <p id="modal-message"></p>
            <a href="#" id="modal-button" class="modal-button"></a>
        </div>
    </div>

    <script>
        // This script will run when the page loads
        window.onload = function() {
            <%-- Check if the JSP has set a message --%>
            <% if (message != null) { %>
                // Get the message details from the JSP variables
                const message = "<%= message %>";
                const messageType = "<%= messageType %>";

                // Get the modal elements
                const modal = document.getElementById('popup-modal');
                const icon = document.getElementById('modal-icon');
                const title = document.getElementById('modal-title');
                const text = document.getElementById('modal-message');
                const button = document.getElementById('modal-button');

                // Configure the modal based on the message type
                if (messageType === 'success') {
                    icon.innerHTML = '<i class="fas fa-check-circle"></i>';
                    icon.className = 'modal-icon success';
                    title.innerText = 'Success!';
                    text.innerText = message;
                    button.innerText = 'Go to Login';
                    button.href = 'user_login.jsp'; // Link to login page
                    button.className = 'modal-button success';
                } else { // 'error'
                    icon.innerHTML = '<i class="fas fa-times-circle"></i>';
                    icon.className = 'modal-icon error';
                    title.innerText = 'Error!';
                    text.innerText = message;
                    button.innerText = 'Close';
                    button.href = '#'; // Just close the modal
                    button.className = 'modal-button error';
                    
                    // Add event listener for the error button to just close the modal
                    button.onclick = function(e) {
                        e.preventDefault();
                        modal.style.display = 'none';
                    };
                }

                // Show the modal
                modal.style.display = 'flex';

                // Close the modal if the overlay is clicked
                modal.onclick = function(event) {
                    if (event.target === modal) {
                        modal.style.display = 'none';
                    }
                };
            <% } %>
        };
    </script>

</body>
</html>