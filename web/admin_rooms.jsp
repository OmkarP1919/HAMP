<%@ page import="java.sql.*, java.util.ArrayList, java.util.HashMap, java.util.List, java.util.Map, java.util.Collections, java.util.Comparator" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR ROOM MANAGEMENT (NO JS FOR FILTERING)
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("admin_id") == null) {
        response.sendRedirect("admin_login.jsp?error=Please login first");
        return;
    }

    String adminName = (String) session.getAttribute("admin_name");

    // --- 2. GATHER DYNAMIC DATA ---
    List<Map<String, Object>> rooms = new ArrayList<>();
    int totalRoomsCount = 0;
    int occupiedSlotsCount = 0;
    int totalSlotsCapacity = 0;

    List<String> uniqueFloors = new ArrayList<>();

    // --- 3. READ FILTER PARAMETERS FROM REQUEST ---
    String floorFilter = request.getParameter("floorFilter");
    String statusFilterAvailable = request.getParameter("statusFilterAvailable"); // Is "on" or null
    String statusFilterOccupied = request.getParameter("statusFilterOccupied");   // Is "on" or null
    String searchTerm = request.getParameter("searchTerm");

    // Determine if this is the initial page load (no filter params sent).
    // This is the key fix to allow checkboxes to be deselected.
    boolean isInitialLoad = (floorFilter == null && statusFilterAvailable == null && statusFilterOccupied == null && searchTerm == null);

    // Set defaults for text/select fields for robustness on any load.
    if (floorFilter == null) floorFilter = "All";
    if (searchTerm == null) searchTerm = "";

    // For checkboxes, ONLY default them to 'on' on the very initial load.
    // On subsequent submissions, a 'null' value means it was intentionally unchecked by the user.
    if (isInitialLoad) {
        statusFilterAvailable = "on";
        statusFilterOccupied = "on";
    }

    // --- 4. DATABASE CONNECTION & QUERIES ---
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    System.out.println("--- admin_rooms.jsp: Starting server-side processing ---");

    try {
        String url = "jdbc:mysql://localhost:3306/hamp";
        String dbUsername = "root";
        String dbPassword = "root";
        // **FIX**: Updated to the modern, correct JDBC driver class name
        String driver = "com.mysql.jdbc.Driver";
        Class.forName(driver);
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        System.out.println("DB Connection successful.");

        // Build the SQL query dynamically based on filters
        StringBuilder sqlBuilder = new StringBuilder("SELECT room_no, floor_no, total_slots, occupied_slots FROM room WHERE hostel_id = 'H1'");
        List<Object> params = new ArrayList<>();

        if (!"All".equals(floorFilter)) {
            sqlBuilder.append(" AND floor_no = ?");
            params.add(Integer.parseInt(floorFilter));
        }

        // Handle status filters
        boolean filterByAvailable = "on".equals(statusFilterAvailable);
        boolean filterByOccupied = "on".equals(statusFilterOccupied);

        if (filterByAvailable && !filterByOccupied) { // Only available
            sqlBuilder.append(" AND occupied_slots = 0");
        } else if (!filterByAvailable && filterByOccupied) { // Only occupied
            sqlBuilder.append(" AND occupied_slots > 0");
        } else if (!filterByAvailable && !filterByOccupied) { // Neither selected
             sqlBuilder.append(" AND 1 = 0"); // A condition that is always false to return no results
        }
        // If both are checked (default), no additional WHERE clause for status needed

        if (!searchTerm.trim().isEmpty()) {
            sqlBuilder.append(" AND room_no LIKE ?");
            params.add("%" + searchTerm.trim() + "%");
        }

        sqlBuilder.append(" ORDER BY floor_no, room_no");

        pstmt = conn.prepareStatement(sqlBuilder.toString());
        System.out.println("Executing query: " + sqlBuilder.toString());

        // Set parameters
        for (int i = 0; i < params.size(); i++) {
            pstmt.setObject(i + 1, params.get(i));
        }

        rs = pstmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> room = new HashMap<>();
            room.put("room_number", rs.getString("room_no"));
            room.put("floor", String.valueOf(rs.getInt("floor_no")));
            room.put("total_slots", rs.getInt("total_slots"));
            room.put("occupied_slots", rs.getInt("occupied_slots"));
            rooms.add(room);
        }
        System.out.println("Total rooms fetched from DB matching filters: " + rooms.size());

        // --- Fetch ALL unique floors for the dropdown (separate query) ---
        try (Statement stmtForFloors = conn.createStatement();
             ResultSet rsForFloors = stmtForFloors.executeQuery("SELECT DISTINCT floor_no FROM room WHERE hostel_id = 'H1' ORDER BY floor_no")) {
            while (rsForFloors.next()) {
                uniqueFloors.add(String.valueOf(rsForFloors.getInt("floor_no")));
            }
        }

        // --- 5. PROCESS FETCHED DATA FOR DISPLAY ---
        totalRoomsCount = rooms.size();
        for(Map<String, Object> r : rooms) {
            int totalSlots = (int) r.get("total_slots");
            int occupiedSlots = (int) r.get("occupied_slots");

            occupiedSlotsCount += occupiedSlots;
            totalSlotsCapacity += totalSlots;

            if (occupiedSlots == 0) {
                r.put("css_class", "available");
            } else {
                r.put("css_class", "occupied");
            }
        }

    } catch (SQLException e) {
        System.err.println("SQL Error loading rooms: " + e.getMessage());
        e.printStackTrace();
        request.setAttribute("errorMessage", "Database error: " + e.getMessage());
    } catch (ClassNotFoundException e) {
        System.err.println("JDBC Driver not found: " + e.getMessage());
        e.printStackTrace();
        request.setAttribute("errorMessage", "JDBC Driver error: " + e.getMessage());
    } catch (Exception e) {
        System.err.println("General Error loading rooms: " + e.getMessage());
        e.printStackTrace();
        request.setAttribute("errorMessage", "Error loading rooms: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (Exception e) { e.printStackTrace(); }
        System.out.println("DB Resources closed.");
    }
    System.out.println("--- admin_rooms.jsp: Finished server-side processing ---");

    double occupancyPercentage = (totalSlotsCapacity > 0) ? ((double) occupiedSlotsCount / totalSlotsCapacity * 100) : 0.0;
    String formattedOccupancy = String.format("%.1f", occupancyPercentage);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937;
            --secondary-color: #f9fafb;
            --accent-color: #2563eb;
            --light-text-color: #6b7280;
            --card-bg: #ffffff;
            --border-color: #e5e7eb;
            --success-color: #10b981; /* Green for Available */
            --occupied-color: #3b82f6; /* Blue for Occupied */
        }
        * { box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif; margin: 0; background-color: var(--secondary-color);
            color: var(--primary-color); height: 100vh; display: grid;
            grid-template-rows: auto 1fr; grid-template-columns: 260px 1fr;
            grid-template-areas: "header header" "sidebar main";
        }
        .top-panel {
            grid-area: header; background: linear-gradient(135deg, var(--accent-color), #4f87ff); color: #ffffff;
            padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; z-index: 10;
        }
        .top-panel h1 { margin: 0; font-size: 1.8em; }
        .user-menu { display: flex; align-items: center; gap: 1.5rem; }
        .user-info { display: flex; align-items: center; gap: 0.75rem; font-weight: 500; }
        .user-info .fa-user-circle { font-size: 1.5rem; }
        .logout-btn {
            display: flex; align-items: center; gap: 0.5rem; background-color: rgba(255, 255, 255, 0.15);
            color: white; padding: 0.5rem 1rem; border-radius: 6px; text-decoration: none;
            font-weight: 500; transition: background-color 0.3s ease;
        }
        .logout-btn:hover { background-color: rgba(255, 255, 255, 0.25); }
        .side-panel {
            grid-area: sidebar; background-color: var(--card-bg); border-right: 1px solid var(--border-color);
            padding: 2rem; display: flex; flex-direction: column;
        }
        .side-panel h2 {
            font-size: 1.2rem; color: var(--primary-color); margin: 0 0 1.5rem 0;
            border-bottom: 1px solid var(--border-color); padding-bottom: 1rem;
        }
        .side-panel-nav { list-style: none; padding: 0; margin: 0; }
        .side-panel-nav li a {
            display: flex; align-items: center; gap: 1rem; padding: 0.8rem 1rem; margin-bottom: 0.5rem;
            text-decoration: none; color: var(--light-text-color); font-weight: 500; border-radius: 6px; transition: all 0.3s ease;
        }
        .side-panel-nav li a:hover { background-color: var(--secondary-color); color: var(--primary-color); }
        .side-panel-nav li a.active { background-color: var(--accent-color); color: white; font-weight: 600; }
        .side-panel-nav li a i { width: 20px; text-align: center; }
        .main-content {
            grid-area: main; padding: 2.5rem; overflow-y: auto;
            display: flex; gap: 2rem;
        }
        .filter-sidebar { width: 280px; flex-shrink: 0; display: flex; flex-direction: column; gap: 1.5rem; }
        .filter-card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; }
        .filter-header { padding: 1rem 1.25rem; border-bottom: 1px solid var(--border-color); }
        .filter-header h3 { margin: 0; font-size: 1.1rem; }
        .filter-body { padding: 1.25rem; }
        .form-group { margin-bottom: 1rem; }
        .form-group label { display: block; font-weight: 500; margin-bottom: 0.5rem; font-size: 0.9rem;}
        .form-group select { width: 100%; padding: 0.5rem; border-radius: 6px; border: 1px solid var(--border-color); }
        .checkbox-group { display: flex; align-items: center; gap: 0.75rem; }
        .checkbox-group input[type="checkbox"] { flex-shrink: 0; margin: 0; }
        .checkbox-group:not(:last-child) { margin-bottom: 0.75rem; }
        .legend-list { list-style: none; padding: 0; margin: 0; }
        .legend-item { display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.5rem; }
        .legend-item .color-box { width: 16px; height: 16px; border-radius: 4px; }
        .quick-actions .action-button {
            width: 100%; display: block; text-align: center;
            padding: 0.8rem; border-radius: 8px; font-weight: 600; text-decoration: none;
            margin-bottom: 0.75rem; transition: background-color 0.2s ease;
        }
        .btn-primary { background-color: var(--accent-color); color: white; }
        .btn-secondary { background-color: var(--primary-color); color: white; }
        .room-display { flex-grow: 1; display: flex; flex-direction: column; min-height: 0; }
        .overview-header {
            display: flex; justify-content: space-between; align-items: center;
            padding-bottom: 1.5rem; flex-shrink: 0;
        }
        .overview-header h1 { margin: 0; font-size: 2rem; }
        .search-bar input { padding: 0.5rem 1rem; border-radius: 8px; border: 1px solid var(--border-color); width: 350px; }
        .room-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 1.25rem; padding: 0;
        }
        .room-card {
            color: white; border-radius: 12px; padding: 1.25rem; text-align: center;
            border: 2px solid transparent; aspect-ratio: 1 / 1; display: flex;
            flex-direction: column; justify-content: space-between; align-items: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1); transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .room-card:hover { transform: translateY(-5px); box-shadow: 0 6px 15px rgba(0,0,0,0.15); }
        .room-card .room-number {
            font-size: 1.8rem; font-weight: 800; margin-bottom: 0.5rem;
            flex-grow: 1; display: flex; align-items: center; justify-content: center;
        }
        .room-card .room-occupancy {
            font-size: 1rem; opacity: 0.95; font-weight: 500;
            background-color: rgba(0,0,0,0.15); padding: 0.4rem 0.8rem; border-radius: 6px;
        }
        .room-card.available { background-color: var(--success-color); border-color: #059669; }
        .room-card.occupied { background-color: var(--occupied-color); border-color: #1d4ed8; }
        @media (max-width: 1200px) {
            .main-content { flex-direction: column; gap: 1.5rem;}
            .filter-sidebar { width: 100%; }
            body { grid-template-columns: 1fr; grid-template-rows: auto auto 1fr; grid-template-areas: "header" "sidebar" "main"; }
            .side-panel { border-right: none; border-bottom: 1px solid var(--border-color); }
        }
        @media (max-width: 768px) {
            .overview-header { flex-direction: column; align-items: flex-start; gap: 1rem; }
            .search-bar input { width: 100%; }
            .room-grid { grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 1rem; }
            .room-card .room-number { font-size: 1.5rem; }
            .room-card .room-occupancy { font-size: 0.85rem; padding: 0.3rem 0.6rem; }
        }
    </style>
</head>
<body>
    <header class="top-panel">
        <div class="logo-title"><h1>Hostel Mate</h1></div>
        <div class="user-menu">
            <span class="user-info"><i class="fas fa-user-circle"></i> Welcome, <%= adminName != null ? adminName : "Admin" %></span>
            <a href="admin_login.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>
    <aside class="side-panel">
        <h2>Admin Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="admin_dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="admin_profile.jsp"><i class="fas fa-user-cog"></i> Profile</a></li>
            <li><a href="admin_applications.jsp"><i class="fas fa-file-signature"></i> Applications</a></li>
            <li><a href="admin_slist.jsp"><i class="fas fa-users"></i> Students</a></li>
            <li><a href="admin_rooms.jsp" class="active"><i class="fas fa-bed"></i> Rooms</a></li>
        </ul>
    </aside>
    <main class="main-content">
        <div class="filter-sidebar">
            <div class="filter-card">
                <div class="filter-header"><h3>Filters & Options</h3></div>
                <div class="filter-body">
                    <%-- This form is now controlled by the new JS function --%>
                    <form action="admin_rooms.jsp" method="get" id="filterForm">
                        <div class="form-group">
                            <label for="floorFilter">Floor</label>
                            <select id="floorFilter" name="floorFilter" onchange="submitFilterForm()">
                                <option value="All" <%= "All".equals(floorFilter) ? "selected" : "" %>>All Floors</option>
                                <% for (String floor : uniqueFloors) { %>
                                    <option value="<%= floor %>" <%= floor.equals(floorFilter) ? "selected" : "" %>><%= floor %> Floor</option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Status</label>
                            <div class="checkbox-group">
                                <input type="checkbox" id="statusFilterOccupied" name="statusFilterOccupied" <%= "on".equals(statusFilterOccupied) ? "checked" : "" %> onchange="submitFilterForm()">
                                <label for="statusFilterOccupied">Occupied</label>
                            </div>
                            <div class="checkbox-group">
                                <input type="checkbox" id="statusFilterAvailable" name="statusFilterAvailable" <%= "on".equals(statusFilterAvailable) ? "checked" : "" %> onchange="submitFilterForm()">
                                <label for="statusFilterAvailable">Available</label>
                            </div>
                        </div>
                        <%-- This hidden input is crucial for preserving the search term --%>
                        <input type="hidden" id="hiddenSearchTerm" name="searchTerm" value="<%= searchTerm %>">
                    </form>
                </div>
            </div>
            <div class="filter-card">
                <div class="filter-header"><h3>Legend</h3></div>
                <div class="filter-body">
                    <ul class="legend-list">
                        <li class="legend-item"><div class="color-box" style="background-color: var(--occupied-color);"></div> Occupied</li>
                        <li class="legend-item"><div class="color-box" style="background-color: var(--success-color);"></div> Available</li>
                    </ul>
                </div>
            </div>
            <div class="filter-card quick-actions">
                <div class="filter-header"><h3>Quick Actions</h3></div>
                <div class="filter-body">
                    <a href="#" class="action-button btn-primary"><i class="fas fa-plus"></i> Add New Room</a>
                    <a href="#" class="action-button btn-secondary"><i class="fas fa-file-export"></i> Export Report</a>
                </div>
            </div>
        </div>
        <div class="room-display">
            <div class="overview-header">
                <div>
                    <h1>Room Overview</h1>
                    <p style="margin:0; color: var(--light-text-color);">Showing: <%= totalRoomsCount %> rooms | Occupancy: <%= formattedOccupancy %>%</p>
                </div>
                <div class="search-bar">
                    <%-- **FIX**: `onkeyup` is removed for better UX. Search is now triggered by Enter key only. --%>
                    <input type="text" id="searchRoom" placeholder="Search room number and press Enter..." value="<%= searchTerm %>">
                </div>
            </div>
            <div id="roomContainer" class="room-grid">
                <% if (rooms.isEmpty()) { %>
                    <p style="text-align: center; margin-top: 2rem; color: var(--light-text-color); grid-column: 1 / -1;">No rooms found matching your criteria.</p>
                <% } else { %>
                    <% for (Map<String, Object> room : rooms) { %>
                        <div class="room-card <%= room.get("css_class") %>">
                            <div class="room-number"><%= room.get("room_number") %></div>
                            <div class="room-occupancy"><%= room.get("occupied_slots") %>/<%= room.get("total_slots") %> Seats</div>
                        </div>
                    <% } %>
                <% } %>
            </div>
        </div>
    </main>

    <script>
        // **FIX**: Centralized function to submit the form.
        // This ensures the search term is always included with any filter change.
        function submitFilterForm() {
            // Get the current value from the visible search bar.
            const searchTermValue = document.getElementById('searchRoom').value;
            // Set the value of the hidden input field inside the form.
            document.getElementById('hiddenSearchTerm').value = searchTermValue;
            // Submit the form.
            document.getElementById('filterForm').submit();
        }

        // **FIX**: Clean event listener for the 'Enter' key on the search bar.
        // It now calls our centralized function.
        document.getElementById('searchRoom').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault(); // Prevent default browser action
                submitFilterForm();
            }
        });
    </script>
</body>
</html>