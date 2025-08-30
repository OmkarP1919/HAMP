<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Site Layout</title>
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
            background-color: var(--secondary-color);
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

        /* Main Content Area Styling */
        .main-content {
            grid-area: main;
            padding: 25px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        /* --- STYLES FOR COMBINED LOGIN/REGISTER AREA --- */

        /* Wrapper for both sections and the divider */
        .auth-wrapper {
            display: flex;
            align-items: center;
            background-color: var(--card-bg);
            padding: 20px 40px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        /* Student Login Form Container */
        .login-container {
            width: 350px;
            padding: 20px;
        }

        .login-container h2 {
            text-align: center;
            margin-top: 0;
            margin-bottom: 25px;
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
        
        /* Divider Styling */
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

        /* New User Register Section Styling */
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
            background-color: #28a745; /* Green color for distinction */
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
                <li><a href="#">Home</a></li>
                <li><a href="#">Login</a></li>
                <li><a href="#">Hostels</a></li>
                <li><a href="#">Apply</a></li>
                <li><a href="#">Downloads</a></li>
                <li><a href="#">Contact Us</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="auth-wrapper">

            <div class="login-container">
                <h2>Student Login</h2>
                <form action="#" method="post">
                    <label for="username">Email/Mobile:</label>
                    <input type="text" id="username" name="username" required>
                    <label for="password">Password:</label>
                    <input type="password" id="password" name="password" required>
                    <input type="submit" value="Login">
                </form>
                <div class="footer">
                    <a href="#">Forgot Password?</a>
                </div>
            </div>

            <div class="divider">
                <div class="or-circle">OR</div>
            </div>

            <div class="register-section">
                <h2>New User?</h2>
                <p>Click the button below to create a new account.</p>
                <a href="#" class="register-button">Register Now</a>
            </div>

        </div>
    </main>

</body>
</html>