<%-- 
    Document   : home_hostels
    Created on : Aug 2, 2025, 10:46:47 AM
    Author     : user
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hostel Details - Campus Hostels</title>
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
            --card-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
        }

        /* General Body and Container Styling */
        body {
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
            background-color: var(--secondary-color);
            color: var(--primary-color);
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 1rem;
        }

        /* Header Styling */
        .header {
            background-color: var(--card-bg);
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .header-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 0;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            text-decoration: none;
        }

        .logo i {
            font-size: 1.5rem;
            color: var(--accent-color);
        }

        .logo span {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary-color);
        }

        .navbar ul {
            list-style: none;
            margin: 0;
            padding: 0;
            display: flex;
            gap: 2rem;
        }

        .navbar a {
            text-decoration: none;
            color: var(--light-text-color);
            font-weight: 500;
            transition: color 0.3s ease;
        }

        .navbar a:hover,
        .navbar a.active {
            color: var(--accent-color);
        }

        /* Hero Section */
        .hero {
            background: linear-gradient(135deg, var(--accent-color), #4f87ff);
            color: white;
            text-align: center;
            padding: 6rem 1rem;
        }

        .hero h1 {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .hero p {
            font-size: 1.25rem;
            font-weight: 400;
            max-width: 800px;
            margin: 0 auto;
            opacity: 0.9;
        }

        /* Main Content Styling */
        .main-content {
            padding: 4rem 0;
        }

        /* Section Title and Subtitle */
        .section-title {
            font-size: 2.25rem;
            font-weight: 700;
            text-align: center;
            color: var(--primary-color);
            margin-bottom: 0.5rem;
        }

        .section-subtitle {
            font-size: 1.1rem;
            text-align: center;
            color: var(--light-text-color);
            max-width: 700px;
            margin: 0 auto 3rem;
        }

        /* Hostel Tabs Styling (Pill-shaped) */
        .hostel-tabs {
            text-align: center;
            margin-bottom: 3rem;
        }

        .tab-button {
            background-color: var(--border-color);
            border: none;
            padding: 0.75rem 1.5rem;
            margin: 0 0.5rem;
            border-radius: 9999px; /* Pill shape */
            cursor: pointer;
            font-weight: 600;
            color: var(--light-text-color);
            transition: all 0.3s ease;
        }

        .tab-button:hover {
            background-color: #d1d5db;
        }

        .tab-button.active {
            background-color: var(--accent-color);
            color: white;
        }

        /* Hostel Category Styling */
        .hostel-category {
            margin-bottom: 4rem;
            transition: opacity 0.3s ease;
        }

        .category-header {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 0.5rem;
            color: var(--primary-color);
        }

        .category-header i {
            font-size: 1.5rem;
            color: var(--accent-color);
        }

        .category-header h2 {
            font-size: 1.5rem;
            font-weight: 600;
            margin: 0;
        }

        .category-subtitle {
            font-size: 0.9rem;
            color: var(--light-text-color);
            margin-bottom: 1.5rem;
        }

        /* Hostel Card Grid */
        .hostel-card-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
        }

        /* Hostel Card Styling (New Design) */
        .hostel-card {
            background-color: var(--card-bg);
            border-radius: 1rem;
            box-shadow: var(--card-shadow);
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .hostel-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
        }

        .card-header {
            color: white;
            padding: 2.5rem 1.5rem;
            text-align: center;
        }

        .card-header h3 {
            font-size: 2rem;
            margin: 0;
            font-weight: 700;
        }

        .card-header p {
            margin: 0.25rem 0 0;
            font-size: 1rem;
        }

        /* Gradient Backgrounds */
        .card-a .card-header { background: linear-gradient(to right, #8a2be2, #6a0dad); }
        .card-b .card-header { background: linear-gradient(to right, #4b0082, #2e0050); }
        .card-c .card-header { background: linear-gradient(to right, #e75480, #c8416d); } 
        .card-d .card-header { background: linear-gradient(to right, #ff69b4, #ff1493); } 
        .card-e .card-header { background: linear-gradient(to right, #ffc0cb, #ff69b4); } 
        .card-f .card-header { background: linear-gradient(to right, #4169e1, #1e90ff); } 
        .card-g .card-header { background: linear-gradient(to right, #3cb371, #2e8b57); } 
        .card-h .card-header { background: linear-gradient(to right, #ffa500, #ff8c00); } 
        .card-i .card-header { background: linear-gradient(to right, #ff6347, #ff4500); } 

        .card-content {
            padding: 1.5rem;
        }

        .info-item {
            display: flex;
            align-items: flex-start;
            gap: 1rem;
            margin-bottom: 1.25rem;
        }

        .info-item i {
            color: var(--accent-color);
            font-size: 1.1rem;
            width: 1.25rem;
            text-align: center;
        }

        .info-item span, .info-item ul {
            margin: 0;
            flex: 1;
        }

        .info-item ul {
            list-style-type: none;
            padding: 0;
            margin-top: 0.25rem;
        }
        
        .info-item li {
            font-size: 0.9rem;
            color: var(--light-text-color);
            margin-bottom: 0.25rem;
            position: relative;
            padding-left: 1.25rem;
        }
        .info-item li::before {
            content: "•";
            color: var(--accent-color);
            position: absolute;
            left: 0;
        }

        /* Ready to Apply Section */
        .apply-section {
            background-color: var(--card-bg);
            padding: 4rem 1rem;
            text-align: center;
            box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.03);
        }

        .apply-section h2 {
            font-size: 2.25rem;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 0.5rem;
        }

        .apply-section p {
            font-size: 1.1rem;
            color: var(--light-text-color);
            margin-bottom: 2rem;
        }

        .apply-buttons {
            display: flex;
            justify-content: center;
            gap: 1.5rem;
            flex-wrap: wrap;
        }

        .btn {
            padding: 0.75rem 2rem;
            border-radius: 9999px;
            border: none;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-primary {
            background-color: var(--accent-color);
            color: white;
        }

        .btn-primary:hover {
            background-color: #1e40af;
        }

        .btn-secondary {
            background-color: white;
            color: var(--accent-color);
            border: 2px solid var(--accent-color);
        }

        .btn-secondary:hover {
            background-color: #eff6ff;
        }

        /* Footer Styling */
        .footer {
            background-color: var(--primary-color);
            color: #d1d9e2;
            padding: 2rem 1rem;
            text-align: center;
        }

        .footer-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 1rem;
        }

        .footer .logo i {
            font-size: 1.75rem;
            color: white;
        }

        .footer .logo span {
            font-size: 1.25rem;
            font-weight: 600;
            color: white;
        }

        .footer p {
            margin: 0;
            font-size: 0.9rem;
            color: #9ca3af;
        }

        .social-icons {
            display: flex;
            gap: 1rem;
        }

        .social-icons a {
            color: #9ca3af;
            font-size: 1.2rem;
            transition: color 0.3s ease;
        }

        .social-icons a:hover {
            color: white;
        }

        /* Utility Class for hiding elements */
        .hidden {
            display: none;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .header-container {
                flex-direction: column;
                gap: 1rem;
            }

            .navbar ul {
                gap: 1rem;
            }
            .hero {
                padding: 4rem 1rem;
            }
            .hero h1 {
                font-size: 2rem;
            }
            .hero p {
                font-size: 1rem;
            }
            .hostel-tabs {
                display: flex;
                flex-direction: column;
                gap: 0.75rem;
            }
        }
    </style>
</head>
<body>

    <header class="header">
        <div class="container header-container">
            <a href="#" class="logo">
                <i class="fas fa-building"></i>
                <span>Campus Hostels</span>
            </a>
            <nav class="navbar">
                <ul>
                    <li><a href="#">Home</a></li>
                    <li><a href="#">Admissions</a></li>
                    <li><a href="#" class="active">Hostels</a></li>
                    <li><a href="#">Contact</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="hero">
        <div class="container">
            <h1>Hostel Details</h1>
            <p>Explore our comfortable and secure hostel accommodations with modern facilities and amenities.</p>
        </div>
    </div>

    <main class="main-content">
        <section class="hostel-details-section">
            <div class="container">
                <div class="hostel-tabs">
                    <button class="tab-button active" data-target="all">All Hostels</button>
                    <button class="tab-button" data-target="girls">Girls Hostels</button>
                    <button class="tab-button" data-target="boys">Boys Hostels</button>
                </div>

                <div class="hostel-category" id="girls-hostels-section">
                    <div class="category-header">
                        <i class="fas fa-venus-double"></i>
                        <h2>Girls Hostels</h2>
                    </div>
                    <p class="category-subtitle">Safe and comfortable accommodation for female students</p>
                    <div class="hostel-card-container">
                        <div class="hostel-card card-a">
                            <div class="card-header"><h3>Hostel A</h3><p>Girls Accommodation</p></div>
                            <div class="card-content">
                                <div class="info-item"><i class="fas fa-user-tie"></i><span>Rector: Mrs.Baravkar Vaishali</span></div>
                                <div class="info-item"><i class="fas fa-cogs"></i><span>Facilities:
                                    <ul><li>24/7 Study Rooms</li><li>24/7 Security & CCTV</li><li>Laundry </li><li>Non-AC Rooms</li></ul></span>
                                </div>
                                <div class="info-item"><i class="fas fa-rupee-sign"></i><span>Fees: 20000/Year</span></div>
                                <div class="info-item"><i class="fas fa-graduation-cap"></i><span>Eligibility: Btech(SY,TY),Msc,B.com,BA</span></div>
                                <div class="info-item"><i class="fas fa-users"></i><span>Total Intake: 408 students</span></div>
                            </div>
                        </div>
                        <div class="hostel-card card-b">
                            <div class="card-header"><h3>Hostel B</h3><p>Girls Accommodation</p></div>
                            <div class="card-content">
                                <div class="info-item"><i class="fas fa-user-tie"></i><span>Rector: Mrs.Deshmukh Bharti</span></div>
                                <div class="info-item"><i class="fas fa-cogs"></i><span>Facilities:
                                     <ul><li>24/7 Study Rooms</li><li>24/7 Security & CCTV</li><li>Laundry </li><li>Non-AC Rooms</li></ul></span>
                                </div>
                                <div class="info-item"><i class="fas fa-rupee-sign"></i><span>Fees: 20000/Year</span></div>
                                <div class="info-item"><i class="fas fa-graduation-cap"></i><span>Eligibility: 11 th and 12 th</span></div>
                                <div class="info-item"><i class="fas fa-users"></i><span>Total Intake: 420 students</span></div>
                            </div>
                        </div>
                        <div class="hostel-card card-c">
                            <div class="card-header"><h3>Hostel C</h3><p>Girls Accommodation</p></div>
                            <div class="card-content">
                                <div class="info-item"><i class="fas fa-user-tie"></i><span>Rector: Mrs.Taware Sunita</span></div>
                                <div class="info-item"><i class="fas fa-cogs"></i><span>Facilities:
                                     <ul><li>24/7 Study Rooms</li><li>24/7 Security & CCTV</li><li>Laundry </li><li>Non-AC Rooms</li></ul></span>
                                </div>
                                <div class="info-item"><i class="fas fa-rupee-sign"></i><span>Fees: 20000/Year</span></div>
                                <div class="info-item"><i class="fas fa-graduation-cap"></i><span>Eligibility: B.com,Bsc,BBA-old</span></div>
                                <div class="info-item"><i class="fas fa-users"></i><span>Total Intake: 186 students</span></div>
                            </div>
                        </div>
                        <div class="hostel-card card-d">
                            <div class="card-header"><h3>Hostel D</h3><p>Girls Accommodation</p></div>
                            <div class="card-content">
                                <div class="info-item"><i class="fas fa-user-tie"></i><span>Rector: Mrs.Adhav Sushma</span></div>
                                <div class="info-item"><i class="fas fa-cogs"></i><span>Facilities:
                                    <ul><li>24/7 Study Rooms</li><li>24/7 Security & CCTV</li><li>Laundry </li><li>Non-AC Rooms</li></ul></span>
                                </div>
                                <div class="info-item"><i class="fas fa-rupee-sign"></i><span>Fees: 20000/Year</span></div>
                                <div class="info-item"><i class="fas fa-graduation-cap"></i><span>Eligibility: Food Tech,Bsc,MBA,Architech</span></div>
                                <div class="info-item"><i class="fas fa-users"></i><span>Total Intake: 490 students</span></div>
                            </div>
                        </div>
                        <div class="hostel-card card-e">
                            <div class="card-header"><h3>Hostel E</h3><p>Girls Accommodation</p></div>
                            <div class="card-content">
                                <div class="info-item"><i class="fas fa-user-tie"></i><span>Rector: Mrs.Nimbalkar Vidya</span></div>
                                <div class="info-item"><i class="fas fa-cogs"></i><span>Facilities:
                                    <ul><li>24/7 Study Rooms</li><li>24/7 Security & CCTV</li><li>Laundry </li><li>Non-AC Rooms</li></ul></span>
                                </div>
                                <div class="info-item"><i class="fas fa-rupee-sign"></i><span>Fees: 20000/Year</span></div>
                                <div class="info-item"><i class="fas fa-graduation-cap"></i><span>Bsc(Asc),ASC-BCA</span></div>
                                <div class="info-item"><i class="fas fa-users"></i><span>Total Intake: 128</span></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="hostel-category" id="boys-hostels-section">
                    <div class="category-header">
                        <i class="fas fa-mars-double"></i>
                        <h2>Boys Hostels</h2>
                    </div>
                    <p class="category-subtitle">Modern facilities and secure environment for male students</p>
                    <div class="hostel-card-container">
                        <div class="hostel-card card-f">
                            <div class="card-header"><h3>Hostel A</h3><p>Boys Accommodation</p></div>
                            <div class="card-content">
                                <div class="info-item"><i class="fas fa-user-tie"></i><span>Rector: Mr.Ekad Vaibhav</span></div>
                                <div class="info-item"><i class="fas fa-cogs"></i><span>Facilities:
                                     <ul><li>24/7 Study Rooms</li><li>24/7 Security & CCTV</li><li>Laundry </li><li>Non-AC Rooms</li></ul></span>
                                </div>
                                <div class="info-item"><i class="fas fa-rupee-sign"></i><span>Fees: 20000/Year</span></div>
                                <div class="info-item"><i class="fas fa-graduation-cap"></i><span>Eligibility: 11 th and 12 th/span></div>
                                <div class="info-item"><i class="fas fa-users"></i><span>Total Intake: 273 students</span></div>
                            </div>
                        </div>
                        <div class="hostel-card card-g">
                            <div class="card-header"><h3>Hostel B</h3><p>Boys Accommodation</p></div>
                            <div class="card-content">
                                <div class="info-item"><i class="fas fa-user-tie"></i><span>Rector: Mr.Uday Thombare</span></div>
                                <div class="info-item"><i class="fas fa-cogs"></i><span>Facilities:
                                    <ul><li>24/7 Study Rooms</li><li>24/7 Security & CCTV</li><li>Laundry </li><li>Non-AC Rooms</li></ul></span>
                                </div>
                                <div class="info-item"><i class="fas fa-rupee-sign"></i><span>Fees: 20000/Year</span></div>
                                <div class="info-item"><i class="fas fa-graduation-cap"></i><span>Eligibility: T.Y,BSc-Agri,Bsc Bio</span></div>
                                <div class="info-item"><i class="fas fa-users"></i><span>Total Intake: 150students</span></div>
                            </div>
                        </div>
                        <div class="hostel-card card-h">
                            <div class="card-header"><h3>Hostel C</h3><p>Boys Accommodation</p></div>
                            <div class="card-content">
                                <div class="info-item"><i class="fas fa-user-tie"></i><span>Rector: Mr.Jagtap Rahul</span></div>
                                <div class="info-item"><i class="fas fa-cogs"></i><span>Facilities:
                                     <ul><li>24/7 Study Rooms</li><li>24/7 Security & CCTV</li><li>Laundry </li><li>Non-AC Rooms</li></ul></span>
                                </div>
                                <div class="info-item"><i class="fas fa-rupee-sign"></i><span>Fees: 20000/Year</span></div>
                                <div class="info-item"><i class="fas fa-graduation-cap"></i><span>Eligibility: BA,L.L.B,Btech</span></div>
                                <div class="info-item"><i class="fas fa-users"></i><span>Total Intake: 198 students</span></div>
                            </div>
                        </div>
                        <div class="hostel-card card-i">
                            <div class="card-header"><h3>Hostel D</h3><p>Boys Accommodation</p></div>
                            <div class="card-content">
                                <div class="info-item"><i class="fas fa-user-tie"></i><span>Rector: Mr.Shitole Sanjay</span></div>
                                <div class="info-item"><i class="fas fa-cogs"></i><span>Facilities:
                                     <ul><li>24/7 Study Rooms</li><li>24/7 Security & CCTV</li><li>Laundry </li><li>Non-AC Rooms</li></ul></span>
                                </div>
                                <div class="info-item"><i class="fas fa-rupee-sign"></i><span>Fees: 20000/Year</span></div>
                                <div class="info-item"><i class="fas fa-graduation-cap"></i><span>Eligibility: SY,TY,Bcom,Food Tech,BCA,Msc,BBA</span></div>
                                <div class="info-item"><i class="fas fa-users"></i><span>Total Intake: 490 students</span></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="apply-section">
            <div class="container text-center">
                <h2>Ready to Apply?</h2>
                <p>Secure your spot in one of our modern hostels. Applications are open for the upcoming semester.</p>
                <div class="apply-buttons">
                    <button class="btn btn-primary"><i class="fas fa-file-alt"></i> Apply Now</button>
                    <button class="btn btn-secondary"><i class="fas fa-download"></i> Download Brochure</button>
                </div>
            </div>
        </section>
    </main>

    <footer class="footer">
        <div class="container footer-container">
            <a href="#" class="logo">
                <i class="fas fa-building"></i>
                <span>Campus Hostels</span>
            </a>
            <p>Providing safe and comfortable accommodation for students</p>
            <div class="social-icons">
                <a href="#"><i class="fab fa-facebook-f"></i></a>
                <a href="#"><i class="fab fa-twitter"></i></a>
                <a href="#"><i class="fab fa-instagram"></i></a>
                <a href="#"><i class="fab fa-linkedin-in"></i></a>
            </div>
        </div>
    </footer>
    
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const tabs = document.querySelectorAll('.tab-button');
            const girlsSection = document.getElementById('girls-hostels-section');
            const boysSection = document.getElementById('boys-hostels-section');

            tabs.forEach(tab => {
                tab.addEventListener('click', () => {
                    tabs.forEach(t => t.classList.remove('active'));
                    tab.classList.add('active');

                    const target = tab.getAttribute('data-target');

                    if (target === 'all') {
                        girlsSection.classList.remove('hidden');
                        boysSection.classList.remove('hidden');
                    } else if (target === 'girls') {
                        girlsSection.classList.remove('hidden');
                        boysSection.classList.add('hidden');
                    } else if (target === 'boys') {
                        girlsSection.classList.add('hidden');
                        boysSection.classList.remove('hidden');
                    }
                });
            });
        });
    </script>
</body>
</html>