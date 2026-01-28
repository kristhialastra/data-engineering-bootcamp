
<h2>Overview</h2>
<p>This design uses a <strong>polyglot persistence</strong> approach, selecting different database types optimized for specific operational needs, then consolidating data for analytics. Answers here are based on the provided readings.</p>
<hr>
<h2>1. Operational Database Design</h2>
<h3>A. Financial Transactions &amp; User Accounts</h3>
<p><strong>Database:</strong> PostgreSQL (RDBMS)</p>
<p><strong>Why:</strong> Money can't disappear or get duplicated. When a passenger in Makati pays ₱250 for a ride, that exact amount must leave their wallet AND arrive in the driver's account atomically. ACID compliance ensures that if any part fails (network drops, payment gateway error), the entire transaction rolls back.</p>
<p><strong>Stores:</strong> User wallets, payment history, ride invoices, driver payouts</p>
<hr>
<h3>B. Real-Time Location Tracking</h3>
<p><strong>Database:</strong> Redis (In-Memory Key-Value Store)</p>
<p><strong>Why:</strong> A car moving through EDSA sends location updates every 2-3 seconds. We need instant read/write with millisecond latency. If one update gets lost (common with mobile data in Metro Manila), it's fine—the next update arrives seconds later. This fits BASE principles: availability and speed over perfect consistency.</p>
<p><strong>Stores:</strong> Current driver locations (lat/long), available car statuses, live ETAs</p>
<hr>
<h3>C. Route Optimization &amp; Matching</h3>
<p><strong>Database:</strong> Neo4j (Graph Database)</p>
<p><strong>Why:</strong> Metro Manila's road network is a web of intersections, one-ways, and traffic patterns. Graph databases excel at relationship traversal: "Find the nearest available driver to a passenger in Ortigas considering actual road connections, not just straight-line distance." This is critical for efficient matching during rush hour.</p>
<p><strong>Stores:</strong> Road network (nodes = intersections, edges = roads with traffic weights), shortest path calculations</p>
<hr>
<h3>D. User Profiles &amp; Car Details</h3>
<p><strong>Database:</strong> MongoDB (Document Store)</p>
<p><strong>Why:</strong> Each user has different preferences: saved addresses ("Home: Quezon City", "Office: BGC"), preferred car types, accessibility needs. A flexible schema lets us add new fields (e.g., "Requires baby seat") without restructuring the entire database.</p>
<p><strong>Stores:</strong> User profiles, saved locations, driver car details (model, plate number, capacity)</p>
<hr>
<h2>2. Data Integration to Analytics Layer</h2>
<h3>Ingestion Strategy: ELT Workflow</h3>
<p><strong>Real-Time Stream Processing:</strong></p>
<ul>
<li>Live GPS data from all active cars → Data Lake</li>
<li>Payment events as they occur → Data Warehouse</li>
<li><strong>Tool:</strong> Apache Kafka or AWS Kinesis for streaming</li>
</ul>
<p><strong>Batch Processing:</strong></p>
<ul>
<li>End-of-day reconciliation of completed trips → Data Warehouse</li>
<li>Historical ride data aggregation → Data Lake</li>
<li><strong>Tool:</strong> Scheduled ETL jobs via Airflow</li>
</ul>
<h3>Storage Architecture: Hybrid Lakehouse</h3>
<p><strong>Data Lake (Raw Storage):</strong></p>
<ul>
<li>Stores ALL raw GPS logs, chat logs, unprocessed events</li>
<li>Cost-effective for massive volume (millions of location pings daily)</li>
</ul>
<p><strong>Data Warehouse (Structured Analytics):</strong></p>
<ul>
<li>Stores cleaned, transformed trip records</li>
<li>Optimized for fast queries by BI tools</li>
<li>Only high-value, validated data</li>
</ul>
<hr>
<h2>3. Data Modeling for Reporting</h2>
<h3>Dimensional Model: Star Schema</h3>
<p>I'll design this around answering business questions like:</p>
<ul>
<li>"Which areas in Metro Manila have highest demand during rush hour?"</li>
<li>"What's the average fare from Quezon City to Makati?"</li>
<li>"Which drivers complete the most trips per week?"</li>
</ul>
<h3>Fact Table: <code>Fact_Trip</code></h3>
<p>Grain: One row per completed trip</p>

Column | Description
-- | --
trip_id | Primary key
driver_id | FK to Dim_Driver
passenger_id | FK to Dim_Passenger
pickup_location_id | FK to Dim_Location
dropoff_location_id | FK to Dim_Location
datetime_id | FK to Dim_DateTime
fare_amount | Measure (₱)
distance_km | Measure
duration_minutes | Measure
traffic_level | Low/Medium/High


<h3>Dimension Tables:</h3>
<p><strong>Dim_Location:</strong></p>
<ul>
<li>location_id, barangay, city, zone (e.g., "CBD", "Residential")</li>
</ul>
<p><strong>Dim_DateTime:</strong></p>
<ul>
<li>datetime_id, date, hour, is_rush_hour, day_of_week, is_holiday</li>
</ul>
<p><strong>Dim_Driver:</strong></p>
<ul>
<li>driver_id, car_model, plate_number, rating, signup_date</li>
</ul>
<p><strong>Dim_Passenger:</strong></p>
<ul>
<li>passenger_id, signup_date, preferred_payment_method</li>
</ul>
<p>This star schema lets analysts quickly slice data:</p>
<ul>
<li>"Total fares by pickup zone during rush hour"</li>
<li>"Average trip distance from BGC to anywhere, by day of week"</li>
</ul>
<hr>
<h2>Real-World Scenario Example</h2>
<p><strong>Problem:</strong> During monsoon season, a driver's GPS cuts out while entering a parking garage in BGC.</p>
<p><strong>How the architecture handles this:</strong></p>
<ol>
<li>Redis (location tracking) simply accepts the next valid update when GPS reconnects—no system failure</li>
<li>The trip record in PostgreSQL remains intact because the payment transaction is separate from location tracking</li>
<li>Analytics in the warehouse later shows this trip had incomplete GPS data, which can be flagged during transformation (dbt cleaning step)</li>
</ol>
<hr>
<h2>Summary</h2><ul>
<li><strong>Operational layer:</strong> Right tool for each job (ACID for money, speed for location, relationships for routing)</li>
<li><strong>Integration layer:</strong> ELT moves data from diverse sources to centralized storage</li>
<li><strong>Analytical layer:</strong> Star schema enables fast, flexible reporting for business decisions</li>
</ul>

submitted by: @kristhiacayle
submitted to: @jgvillanuevastratpoint
submission date: 01/27/26
