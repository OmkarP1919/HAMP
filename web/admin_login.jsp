<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Login</title>
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
            font-family: 'Inter', sans-serif;
            background: var(--secondary-color);
            margin: 0;
            display: flex; /* Use flexbox for layout */
            flex-direction: column; /* Stack children vertically */
            height: 100vh; /* Full viewport height */
        }

        /* --- Top Panel Styling --- */
        .top-panel {
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

        /* --- Main Content Area --- */
        .main-content {
            flex-grow: 1; /* Allow this area to grow and fill remaining space */
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        /* --- Login Form Styling --- */
        .login-container {
            background-color: var(--card-bg);
            padding: 40px 50px; 
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 450px; 
        }

        .login-container h2 {
            text-align: center;
            margin-top: 0;
            margin-bottom: 30px;
            color: var(--primary-color);
            font-size: 1.8em;
        }

        .login-container label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600; /* Semibold */
            color: var(--primary-color);
        }

        .login-container input[type="text"],
        .login-container input[type="password"] {
            width: 100%;
            padding: 12px;
            margin-bottom: 20px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 1em;
        }

        .login-container input[type="submit"] {
            width: 100%;
            background-color: var(--accent-color);
            color: white;
            padding: 14px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }

        .login-container input[type="submit"]:hover {
            background-color: #1e40af; /* Darker shade of accent color */
        }

        .footer {
            text-align: center;
            font-size: 13px;
            margin-top: 20px;
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
    </style>
</head>
<body>

    <header class="top-panel">
        <h1>Hostel Mate</h1>
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
        <div class="login-container">
            <h2>Admin Login</h2>
            <form action="admin_dashboard.jsp" method="post">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>

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