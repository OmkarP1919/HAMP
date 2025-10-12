<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat, java.text.SimpleDateFormat, java.math.BigDecimal" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR FEE PAYMENT PAGE
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("user_roll_no") == null) {
        response.sendRedirect("user_login.jsp?error=Please login first");
        return;
    }
    String userRollNo = (String) session.getAttribute("user_roll_no");

    // --- 2. INITIALIZE VARIABLES ---
    String fullName = "";
    String applicationStatus = null; // Can be null, "Pending", "Approved", "Rejected"
    
    HashMap<String, Object> outstandingFee = null; // Stores details of an UNPAID fee, if any
    boolean hasOutstandingFee = false;
    
    ArrayList<HashMap<String, Object>> paymentHistory = new ArrayList<>();

    String paymentSuccessMessage = request.getParameter("paymentSuccess"); // New: to display success
    String paymentErrorMessage = request.getParameter("paymentError");     // New: to display errors

    // --- 3. DATABASE OPERATIONS ---
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String url = "jdbc:mysql://localhost:3306/hamp";
        String dbUsername = "root";                   
        String dbPassword = "root";                     
        String driver = "com.mysql.jdbc.Driver"; 
        Class.forName(driver);
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);

        // Get student's full name
        pstmt = conn.prepareStatement("SELECT fullname FROM student_auth WHERE roll_no = ?");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("fullname");
        }
        rs.close(); // Close ResultSet after use
        pstmt.close(); // Close PreparedStatement after use

        // Get the latest application status for the student
        pstmt = conn.prepareStatement("SELECT status FROM applications WHERE stud_roll = ? ORDER BY applied_date DESC LIMIT 1");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            applicationStatus = rs.getString("status");
        }
        rs.close();
        pstmt.close();

        // If application is Approved, check for outstanding fees AND payment history
        if ("Approved".equals(applicationStatus)) {
            // Check for an UNPAID fee
            pstmt = conn.prepareStatement("SELECT payment_id, total_fees, payment_status FROM fees WHERE roll_no = ? AND payment_status = 'Unpaid' LIMIT 1");
            pstmt.setString(1, userRollNo);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                outstandingFee = new HashMap<>();
                outstandingFee.put("payment_id", rs.getInt("payment_id"));
                outstandingFee.put("total_fees", rs.getBigDecimal("total_fees"));
                outstandingFee.put("payment_status", rs.getString("payment_status"));
                hasOutstandingFee = true;
            }
            rs.close();
            pstmt.close();

            // Fetch PAID payment history (regardless of outstanding fee status)
            pstmt = conn.prepareStatement("SELECT payment_id, payment_date, paid_fees, payment_mode, payment_status FROM fees WHERE roll_no = ? AND payment_status = 'Paid' ORDER BY payment_date DESC");
            pstmt.setString(1, userRollNo);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                HashMap<String, Object> historyItem = new HashMap<>();
                historyItem.put("payment_id", rs.getInt("payment_id"));
                historyItem.put("payment_date", rs.getDate("payment_date"));
                historyItem.put("paid_fees", rs.getBigDecimal("paid_fees"));
                historyItem.put("payment_mode", rs.getString("payment_mode"));
                historyItem.put("payment_status", rs.getString("payment_status"));
                paymentHistory.add(historyItem);
            }
            rs.close();
            pstmt.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
        paymentErrorMessage = "An unexpected error occurred: " + e.getMessage();
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }

    // Formatters for currency and date
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM, yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hostel Fee Payment</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937; --secondary-color: #f9fafb; --accent-color: #2563eb;
            --light-text-color: #6b7280; --card-bg: #ffffff; --border-color: #e5e7eb;
            --success-color: #10b981; --success-bg: #f0fdf4; --success-border: #a7f3d0;
            --warning-color: #f59e0b; --warning-bg: #fffbeb; --warning-border: #fde68a;
            --error-color: #ef4444; --error-bg: #fef2f2; --error-border: #fca5a5;
        }
        * { box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; margin: 0; background-color: var(--secondary-color); color: var(--primary-color); height: 100vh; display: grid; grid-template-rows: auto 1fr; grid-template-columns: 260px 1fr; grid-template-areas: "header header" "sidebar main"; }
        .top-panel { grid-area: header; background: linear-gradient(135deg, var(--accent-color), #4f87ff); color: #ffffff; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; z-index: 10; }
        .top-panel h1 { margin: 0; font-size: 1.8em; }
        .user-menu { display: flex; align-items: center; gap: 1.5rem; }
        .user-info { display: flex; align-items: center; gap: 0.75rem; font-weight: 500; }
        .user-info .fa-user-circle { font-size: 1.5rem; }
        .logout-btn { display: flex; align-items: center; gap: 0.5rem; background-color: rgba(255, 255, 255, 0.15); color: white; padding: 0.5rem 1rem; border-radius: 6px; text-decoration: none; font-weight: 500; transition: background-color 0.3s ease; }
        .logout-btn:hover { background-color: rgba(255, 255, 255, 0.25); }
        .side-panel { grid-area: sidebar; background-color: var(--card-bg); border-right: 1px solid var(--border-color); padding: 2rem; display: flex; flex-direction: column; }
        .side-panel h2 { font-size: 1.2rem; color: var(--primary-color); margin: 0 0 1.5rem 0; border-bottom: 1px solid var(--border-color); padding-bottom: 1rem; }
        .side-panel-nav { list-style: none; padding: 0; margin: 0; }
        .side-panel-nav li a { display: flex; align-items: center; gap: 1rem; padding: 0.8rem 1rem; margin-bottom: 0.5rem; text-decoration: none; color: var(--light-text-color); font-weight: 500; border-radius: 6px; transition: all 0.3s ease; }
        .side-panel-nav li a:hover { background-color: var(--secondary-color); color: var(--primary-color); }
        .side-panel-nav li a.active { background-color: var(--accent-color); color: white; font-weight: 600; }
        .side-panel-nav li a i { width: 20px; text-align: center; }
        .main-content { grid-area: main; padding: 2.5rem; overflow-y: auto; display: flex; justify-content: center; }
        .payment-dashboard { width: 100%; max-width: 900px; display: flex; flex-direction: column; gap: 2.5rem; }
        .card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .card-header { padding: 1rem 1.5rem; border-bottom: 1px solid var(--border-color); }
        .card-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }
        .card-body { padding: 1.5rem; }
        .status-banner { display: flex; align-items: center; gap: 1rem; padding: 1.5rem; border-radius: 12px; border: 1px solid; }
        .status-banner i { font-size: 1.8rem; }
        .status-banner-text h3 { margin: 0; font-size: 1.2rem; font-weight: 700; }
        .status-banner-text p { margin: 0.25rem 0 0; color: var(--light-text-color); }
        .status-due { background-color: var(--warning-bg); border-color: var(--warning-border); color: #92400e; }
        .status-paid { background-color: var(--success-bg); border-color: var(--success-border); color: #065f46; }
        .status-info { background-color: #eff6ff; border-color: #bfdbfe; color: #1e40af; }
        .status-error { background-color: var(--error-bg); border-color: var(--error-border); color: var(--error-color); }
        .details-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem 2rem; }
        .detail-item .label { font-size: 0.9rem; color: var(--light-text-color); }
        .detail-item .value { font-size: 1.1rem; font-weight: 600; margin-top: 0.25rem; }
        .receipt-button { display: inline-flex; align-items: center; gap: 0.75rem; text-decoration: none; background-color: var(--accent-color); color: white; padding: 0.8rem 1.5rem; border-radius: 8px; font-weight: 600; transition: background-color 0.2s ease; }
        .receipt-button:hover { background-color: #1d4ed8; }
        .receipt-button i { font-size: 1.2rem; }
        .card-footer { padding: 1rem 1.5rem; border-top: 1px solid var(--border-color); background-color: var(--secondary-color); }
        .table-container { width: 100%; overflow-x: auto; }
        .history-table { width: 100%; border-collapse: collapse; }
        .history-table th, .history-table td { padding: 1rem; text-align: left; border-bottom: 1px solid var(--border-color); }
        .history-table th { font-size: 0.8rem; text-transform: uppercase; color: var(--light-text-color); background-color: var(--secondary-color); }
        .history-table tr:last-child td { border-bottom: none; }
        .status-badge { padding: 0.3rem 0.8rem; border-radius: 1rem; font-size: 0.85rem; font-weight: 600; color: white; }
        .status-badge.paid { background-color: var(--success-color); }
        .invoice-total { text-align: center; padding: 2rem; }
        .invoice-total p { margin: 0; font-size: 1rem; color: var(--light-text-color); }
        .invoice-total .amount { font-size: 3.5rem; font-weight: 800; color: var(--primary-color); margin-top: 0.5rem; }
        .payment-methods input[type="radio"] { display: none; }
        .payment-methods { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 1rem; }
        .method-card { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 1.5rem 1rem; border: 2px solid var(--border-color); border-radius: 8px; cursor: pointer; transition: all 0.2s ease-in-out; font-weight: 600; gap: 0.75rem; }
        .method-card:hover { border-color: var(--accent-color); color: var(--accent-color); }
        .method-card i { font-size: 2rem; }
        .payment-methods input[type="radio"]:checked + .method-card { border-color: var(--accent-color); background-color: #eff6ff; color: var(--accent-color); box-shadow: 0 0 0 2px var(--accent-color); }
        .pay-button { width: 100%; padding: 1rem; border: none; border-radius: 8px; background-color: var(--accent-color); color: white; font-size: 1.2rem; font-weight: 700; cursor: pointer; transition: background-color 0.3s ease; display: flex; align-items: center; justify-content: center; gap: 0.5rem; margin-top: 1.5rem; }
        .pay-button:hover { background-color: #1d4ed8; }
        @media (max-width: 992px) {
            body { grid-template-columns: 1fr; grid-template-rows: auto auto 1fr; grid-template-areas: "header" "sidebar" "main"; }
            .side-panel { border-right: none; border-bottom: 1px solid var(--border-color); }
        }
    </style>
</head>
<body>
    <header class="top-panel">
        <div class="logo-title"><h1>Hostel Mate</h1></div>
        <div class="user-menu">
            <span class="user-info"><i class="fas fa-user-circle"></i> Welcome, <%= fullName %></span>
            <a href="user_login.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>
    <aside class="side-panel">
        <h2>Student Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="user_dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="user_apply.jsp"><i class="fas fa-file-alt"></i> Apply</a></li>
            <li><a href="user_profile.jsp"><i class="fas fa-user-circle"></i> Profile</a></li>
            <li><a href="user_downloads.jsp"><i class="fas fa-download"></i> Downloads</a></li>
            <li><a href="user_payfees.jsp" class="active"><i class="fas fa-file-invoice-dollar"></i> Payments</a></li>
            <li><a href="user_status.jsp"><i class="fas fa-check-circle"></i> Status</a></li>
        </ul>
    </aside>
    <main class="main-content">
        <div class="payment-dashboard">

            <%-- Display success or error messages from payment processing --%>
            <% if (paymentSuccessMessage != null) { %>
                <div class="status-banner status-paid">
                    <i class="fas fa-check-circle"></i>
                    <div class="status-banner-text">
                        <h3>Payment Successful!</h3>
                        <p><%= paymentSuccessMessage %></p>
                    </div>
                </div>
            <% } else if (paymentErrorMessage != null) { %>
                <div class="status-banner status-error">
                    <i class="fas fa-times-circle"></i>
                    <div class="status-banner-text">
                        <h3>Payment Failed!</h3>
                        <p><%= paymentErrorMessage %></p>
                    </div>
                </div>
            <% } %>

            <%-- Conditional rendering based on application status and outstanding fees --%>
            <% if (!"Approved".equals(applicationStatus)) { %>
                <div class="status-banner status-info">
                    <i class="fas fa-info-circle"></i>
                    <div class="status-banner-text">
                        <h3>Payment Section Locked</h3>
                        <p>Your application status is currently '<%= applicationStatus == null ? "Not Applied" : applicationStatus %>'. Payment options will become available once your application is approved.</p>
                    </div>
                </div>

            <% } else if (hasOutstandingFee) { %>
                <div class="status-banner status-due">
                    <i class="fas fa-exclamation-triangle"></i>
                    <div class="status-banner-text">
                        <h3>Your Payment is Due</h3>
                        <p>Please complete the payment to finalize your hostel allocation.</p>
                    </div>
                </div>

                <form action="process_mock_payment.jsp" method="POST" class="card">
                    <div class="card-header"><h2>Complete Your Payment</h2></div>
                    <div class="card-body">
                        <div class="invoice-total">
                            <p>Total Amount Due</p>
                            <div class="amount"><%= currencyFormatter.format(outstandingFee.get("total_fees")) %></div>
                            <input type="hidden" name="payment_id" value="<%= outstandingFee.get("payment_id") %>">
                            <input type="hidden" name="amount_due" value="<%= outstandingFee.get("total_fees") %>"> <%-- Pass total_fees as amount_due --%>
                        </div>
                        <div class="payment-methods">
                            <input type="radio" id="upi" name="payment_mode" value="UPI" checked><label for="upi" class="method-card"><i class="fab fa-google-pay"></i><span>UPI</span></label>
                            <input type="radio" id="card" name="payment_mode" value="Card"><label for="card" class="method-card"><i class="fas fa-credit-card"></i><span>Card</span></label>
                            <input type="radio" id="netbanking" name="payment_mode" value="NetBanking"><label for="netbanking" class="method-card"><i class="fas fa-university"></i><span>Net Banking</span></label>
                        </div>
                        <button type="submit" class="pay-button"><i class="fas fa-shield-alt"></i> Proceed to Pay</button>
                    </div>
                </form>

            <% } else { %> <%-- Application Approved, and no outstanding 'Unpaid' fee --%>
                

                <div class="card">
                    <div class="card-header"><h2>Last Transaction Details</h2></div>
                    <% if (!paymentHistory.isEmpty()) { 
                        HashMap<String, Object> lastPayment = paymentHistory.get(0); // Get the most recent paid transaction
                    %>
                    <div class="card-body">
                        <div class="details-grid">
                            <div class="detail-item">
                                <div class="label">Payment ID</div>
                                <div class="value">PAY-<%= lastPayment.get("payment_id") %></div>
                            </div>
                            <div class="detail-item">
                                <div class="label">Payment Date</div>
                                <div class="value"><%= sdf.format((java.util.Date)lastPayment.get("payment_date")) %></div>
                            </div>
                            <div class="detail-item">
                                <div class="label">Payment Mode</div>
                                <div class="value"><%= lastPayment.get("payment_mode") %></div>
                            </div>
                            <div class="detail-item">
                                <div class="label">Amount Paid</div>
                                <div class="value"><%= currencyFormatter.format(lastPayment.get("paid_fees")) %></div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <a href="generate-receipt.jsp?id=<%= lastPayment.get("payment_id") %>" class="receipt-button">
                            <i class="fas fa-download"></i> Download Receipt
                        </a>
                    </div>
                    <% } else { %>
                        <div class="card-body">
                            <p style="text-align: center; color: var(--light-text-color);">No recent payment details found, but your dues are clear!</p>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <div class="card">
                <div class="card-header"><h2>Payment History</h2></div>
                <div class="table-container">
                    <table class="history-table">
                        <thead>
                            <tr>
                                <th>Payment ID</th>
                                <th>Date</th>
                                <th>Amount</th>
                                <th>Mode</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (paymentHistory.isEmpty()) { %>
                                <tr><td colspan="5" style="text-align: center; color: var(--light-text-color); padding: 2rem;">No payment history found.</td></tr>
                            <% } else { 
                                for(HashMap<String, Object> item : paymentHistory) {
                            %>
                                <tr>
                                    <td>PAY-<%= item.get("payment_id") %></td>
                                    <td><%= sdf.format((java.util.Date)item.get("payment_date")) %></td>
                                    <td><%= currencyFormatter.format(item.get("paid_fees")) %></td>
                                    <td><%= item.get("payment_mode") %></td>
                                    <td><span class="status-badge paid"><%= item.get("payment_status") %></span></td>
                                </tr>
                            <%  } 
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</body>
</html>