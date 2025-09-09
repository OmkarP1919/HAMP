<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Registration</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937;
            --secondary-color: #f9fafb;
            --accent-color: #2563eb;
            --light-text-color: #6b7280;
            --card-bg: #ffffff;
            --border-color: #e5e7eb;
        }

        /* Basic reset and body styling */
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
            background: var(--secondary-color);
        }

        /* Top Panel Styling */
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

        /* Navigation Bar Styling */
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
        /* --- NEW DROPDOWN STYLES --- */
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

        /* Main Content Area Styling */
        .main-content {
            grid-area: main;
            padding: 40px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow-y: auto;
        }
        
        /* --- STYLES FOR COMBINED AUTH AREA --- */

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

        /* Registration Form Container (Left Side) */
        .register-form-container {
            width: 100%;
            padding: 20px;
        }

        .register-form-container h2 {
            text-align: center;
            margin-top: 0;
            margin-bottom: 25px;
            color: var(--primary-color);
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--primary-color);
        }

        .form-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 1em;
        }
        
        .name-row {
            display: flex;
            gap: 15px;
        }
        
        .password-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .submit-btn {
            width: 100%;
            background-color: #28a745;
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

        .submit-btn:hover {
            background-color: #218838;
        }

        /* Divider Styling */
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
            background-color: var(--secondary-color);
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

        /* Login Prompt Section (Right Side) */
        .login-prompt-section {
            width: 100%;
            max-width: 300px;
            padding: 20px;
            text-align: center;
        }

        .login-prompt-section h2 {
            margin-top: 0;
            margin-bottom: 25px;
            color: var(--primary-color);
        }

        .login-prompt-section p {
            font-size: 1.1em;
            color: var(--light-text-color);
            margin-bottom: 30px;
        }

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

        .login-prompt-section a.login-button:hover {
            background-color: #1e40af;
        }

        /* Responsive layout */
        @media (max-width: 992px) {
            .auth-wrapper {
                flex-direction: column;
                max-width: 500px;
            }
            .divider {
                height: auto;
                width: 80%;
                border-left: none;
                border-top: 1px solid var(--border-color);
                margin: 30px 0;
            }
        }
        @media (max-width: 480px) {
             .name-row, .password-row {
                flex-direction: column;
                grid-template-columns: 1fr;
             }
        }
    </style>
</head>
<body>

    <header class="top-panel">
        <h1>HOSTEL MATE</h1>
        <nav class="navbar">
                <ul>
                    <li><a href="index.html">Home</a></li>
                    <!-- UPDATED LOGIN DROPDOWN -->
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

            <div class="register-form-container">
                <h2>Create an Account</h2>
                <form action="#" method="post">
                    
                    <div class="form-group">
                        <label>Full Name:</label>
                        <div class="name-row">
                            <input type="text" name="first_name" placeholder="First Name" required>
                            <input type="text" name="last_name" placeholder="Last Name" required>
                        </div>
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
                <a href="#" class="login-button">Login Now</a>
            </div>

        </div>
    </main>

</body>
</html>