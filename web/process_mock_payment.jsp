<%@ page import="java.sql.*, java.math.BigDecimal" %>

<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("user_roll_no") == null) {
        response.sendRedirect("user_login.jsp?error=Please login first");
        return;
    }
    String userRollNo = (String) session.getAttribute("user_roll_no");

    // --- 2. GET PAYMENT DETAILS FROM FORM ---
    String paymentIdStr = request.getParameter("payment_id");
    String amountDueStr = request.getParameter("amount_due");
    String paymentMode = request.getParameter("payment_mode");

    String redirectUrl = "user_payfees.jsp"; // Default redirect

    if (paymentIdStr == null || paymentIdStr.isEmpty() || amountDueStr == null || amountDueStr.isEmpty() || paymentMode == null || paymentMode.isEmpty()) {
        response.sendRedirect(redirectUrl + "?paymentError=Missing payment details. Please try again.");
        return;
    }

    int paymentId = 0;
    BigDecimal amountDue = BigDecimal.ZERO;
    try {
        paymentId = Integer.parseInt(paymentIdStr);
        amountDue = new BigDecimal(amountDueStr);
    } catch (NumberFormatException e) {
        response.sendRedirect(redirectUrl + "?paymentError=Invalid amount or payment ID format.");
        return;
    }

    // --- 3. DATABASE OPERATIONS (MOCK PAYMENT) ---
    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        String url = "jdbc:mysql://localhost:3306/hamp";
        String dbUsername = "root";
        String dbPassword = "root";
        String driver = "com.mysql.jdbc.Driver";
        Class.forName(driver);
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);

        // Update the fee record to 'Paid'
        pstmt = conn.prepareStatement(
            "UPDATE fees SET payment_status = 'Paid', paid_fees = ?, payment_mode = ?, payment_date = CURDATE() WHERE payment_id = ? AND roll_no = ?"
        );
        pstmt.setBigDecimal(1, amountDue); // Assuming full amount is paid
        pstmt.setString(2, paymentMode);
        pstmt.setInt(3, paymentId);
        pstmt.setString(4, userRollNo); // Ensure this payment belongs to the logged-in student

        int rowsAffected = pstmt.executeUpdate();

        if (rowsAffected > 0) {
            // Payment successful
            response.sendRedirect(redirectUrl + "?paymentSuccess=Your payment for " + amountDueStr + " via " + paymentMode + " was successful.");
        } else {
            // No record found or updated (e.g., already paid, invalid ID)
            response.sendRedirect(redirectUrl + "?paymentError=Could not process payment. Fee record not found or already paid.");
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(redirectUrl + "?paymentError=An unexpected error occurred during payment processing: " + e.getMessage());
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>