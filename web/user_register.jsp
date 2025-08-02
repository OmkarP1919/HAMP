<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Registration - Horizontal Form</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }

        .register-container {
            background-color: #fff;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            width: 600px;
        }

        .register-container h2 {
            text-align: center;
            margin-bottom: 30px;
            color: #333;
        }

        .form-group {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
        }

        .form-group label {
            flex: 0 0 150px;
            font-weight: bold;
            margin-right: 10px;
        }

        .form-group input {
            flex: 1;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
        }

        .name-row {
            display: flex;
            gap: 10px;
            flex: 1;
        }

        .name-row input {
            flex: 1;
        }

        .form-group input[type="submit"] {
            background-color: #28a745;
            color: white;
            border: none;
            cursor: pointer;
            font-size: 16px;
            transition: background 0.3s;
        }

        .form-group input[type="submit"]:hover {
            background-color: #218838;
        }

        .footer {
            text-align: center;
            margin-top: 20px;
            font-size: 13px;
            color: #777;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <h2>User Registration</h2>
        <form action="userRegisterProcess.jsp" method="post">
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
                <input type="tel" id="phone" name="phone" pattern="[0-9]{10}" maxlength="10" required>
            </div>

            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>

            <div class="form-group">
                <label for="cpassword">Confirm Password:</label>
                <input type="password" id="cpassword" name="confirm_password" required>
            </div>

         <div class="form-group" style="justify-content: center;">
    <input type="submit" value="Register" style="width: 100%;">
         </div>

        </form>
        <span>Already registered<a href=""> Click Here</a></span>
    </div>
</body>
</html>
