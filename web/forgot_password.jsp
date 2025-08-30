<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Hostel Mate</title>
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
        }

        /* Basic reset and body styling */
        * {
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--secondary-color);
            margin: 0;
            display: flex;
            flex-direction: column;
            height: 100vh;
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

        /* --- Main Content Area --- */
        .main-content {
            flex-grow: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 2rem;
        }

        /* --- Forgot Password Form Styling --- */
        .forgot-password-container {
            background-color: var(--card-bg);
            padding: 40px 50px;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 500px;
        }

        .forgot-password-container h2 {
            text-align: center;
            margin-top: 0;
            margin-bottom: 1rem;
            color: var(--primary-color);
            font-size: 1.8em;
        }
        
        .forgot-password-container p.instructions {
            text-align: center;
            color: var(--light-text-color);
            margin-bottom: 2rem;
            font-size: 1rem;
        }

        .form-group {
            margin-bottom: 1.25rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
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

        .submit-btn {
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
            margin-top: 1rem;
        }

        .submit-btn:hover {
            background-color: #1e40af;
        }

        .back-to-login {
            text-align: center;
            font-size: 0.9rem;
            margin-top: 1.5rem;
        }

        .back-to-login a {
            text-decoration: none;
            color: var(--accent-color);
            font-weight: 500;
        }

        .back-to-login a:hover {
            text-decoration: underline;
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
        <div class="forgot-password-container">
            <h2>Reset Your Password</h2>
            <p class="instructions">Please enter your details to verify your identity. A password reset link will be sent to your registered email address.</p>
            
            <form action="#" method="post">
                <div class="form-group">
                    <label for="email">Registered Email Address</label>
                    <input type="email" id="email" name="email" required>
                </div>
                

                <div class="form-group">
                    <label for="phone">Registered Mobile Number</label>
                    <input type="tel" id="phone" name="phone" pattern="[0-9]{10}" maxlength="10" required>
                </div>

                <div class="form-group">
                    <label for="dob">Date of Birth</label>
                    <input type="date" id="dob" name="dob" required>
                </div>

                <button type="submit" class="submit-btn">Send Reset Link</button>
            </form>

            <div class="back-to-login">
                <p>Remember your password? <a href="#">Back to Login</a></p>
            </div>
        </div>
    </main>
    
</body>
</html>