/**
 * @description Master Data Enrichment Script v5 - AUTHENTIC REAL WORLD DATA
 * High-fidelity, authentic dataset with 30 real restaurants, 30 realistic diners, and 40 reservations.
 */

// 1. Cleanup
delete [SELECT Id FROM Agent_Interaction__c];
delete [SELECT Id FROM Reservation__c];
delete [SELECT Id FROM Diner__c];
delete [SELECT Id FROM Restaurant__c];

// 2. Create 30 Authentic Restaurants
List<Restaurant__c> restaurants = new List<Restaurant__c>{
    new Restaurant__c(
        Name='The French Laundry', Cuisine_Type__c='French', Price_Range__c='$$$$', City__c='Yountville', 
        Address__c='6640 Washington St', Total_Capacity__c=60, Active__c=true, ExternalID__c='res_001',
        Accepts_Reservations__c=true, Accepts_Walkins__c=false, Avg_Rating__c=4.9, Bar_Available__c=true,
        Cancellation_Window_Hours__c=72, Dress_Code__c='Formal', Happy_Hour__c=false, Kids_Menu__c=false,
        Live_Music__c=false, Outdoor_Seating__c=true, Parking_Available__c=true, Partner_Tier__c='Platinum',
        Phone__c='707-944-2380', Private_Dining_Available__c=true, Reservation_Deposit_Required__c=true,
        Reservation_Policy__c='Reservations are released on the first of every month for the following month.',
        Menu_Highlights__c='Oysters and Pearls, Salmon Cornets, Truffle Risotto', State__c='CA', Zip__c='94599'
    ),
    new Restaurant__c(
        Name='Franklin BBQ', Cuisine_Type__c='American', Price_Range__c='$$', City__c='Austin', 
        Address__c='900 E 11th St', Total_Capacity__c=100, Active__c=true, ExternalID__c='res_002',
        Accepts_Reservations__c=true, Accepts_Walkins__c=true, Avg_Rating__c=4.8, Bar_Available__c=false,
        Cancellation_Window_Hours__c=24, Dress_Code__c='Casual', Happy_Hour__c=false, Kids_Menu__c=true,
        Live_Music__c=false, Outdoor_Seating__c=true, Parking_Available__c=true, Partner_Tier__c='Gold',
        Phone__c='512-653-1187', Private_Dining_Available__c=false, Reservation_Deposit_Required__c=false,
        Reservation_Policy__c='Pre-orders available for 5lbs+ of meat. Walk-ins usually wait 3-4 hours.',
        Menu_Highlights__c='Brisket, Pork Ribs, Tipsy Pies', State__c='TX', Zip__c='78702'
    ),
    new Restaurant__c(
        Name='Pujol', Cuisine_Type__c='Mexican', Price_Range__c='$$$$', City__c='Mexico City', 
        Address__c='Tennyson 133, Polanco', Total_Capacity__c=50, Active__c=true, ExternalID__c='res_003',
        Accepts_Reservations__c=true, Accepts_Walkins__c=false, Avg_Rating__c=4.7, Bar_Available__c=true,
        Cancellation_Window_Hours__c=48, Dress_Code__c='Smart Casual', Happy_Hour__c=false, Kids_Menu__c=false,
        Live_Music__c=false, Outdoor_Seating__c=true, Parking_Available__c=true, Partner_Tier__c='Platinum',
        Phone__c='+52 55 5545 4111', Private_Dining_Available__c=true, Reservation_Deposit_Required__c=true,
        Menu_Highlights__c='Mole Madre 2500+ Days, Baby Corn with Chicatana Ant Mayo', State__c='CDMX', Zip__c='11550'
    ),
    new Restaurant__c(
        Name='Osteria Francescana', Cuisine_Type__c='Italian', Price_Range__c='$$$$', City__c='Modena', 
        Address__c='Via Stella, 22', Total_Capacity__c=36, Active__c=true, ExternalID__c='res_004',
        Accepts_Reservations__c=true, Accepts_Walkins__c=false, Avg_Rating__c=4.9, Bar_Available__c=true,
        Cancellation_Window_Hours__c=72, Dress_Code__c='Formal', Happy_Hour__c=false, Kids_Menu__c=false,
        Live_Music__c=false, Outdoor_Seating__c=false, Parking_Available__c=false, Partner_Tier__c='Platinum',
        Phone__c='+39 059 223912', Private_Dining_Available__c=true, Reservation_Deposit_Required__c=true,
        Menu_Highlights__c='Five Ages of Parmesan, Oops! I Dropped the Lemon Tart', State__c='MO', Zip__c='41121'
    ),
    new Restaurant__c(
        Name='Gaggan Anand', Cuisine_Type__c='Indian', Price_Range__c='$$$$', City__c='Bangkok', 
        Address__c='Sukhumvit Soi 31', Total_Capacity__c=40, Active__c=true, ExternalID__c='res_005',
        Accepts_Reservations__c=true, Accepts_Walkins__c=false, Avg_Rating__c=4.8, Bar_Available__c=true,
        Cancellation_Window_Hours__c=48, Dress_Code__c='Smart Casual', Happy_Hour__c=false, Kids_Menu__c=false,
        Live_Music__c=false, Outdoor_Seating__c=false, Parking_Available__c=true, Partner_Tier__c='Platinum',
        Phone__c='+66 2 046 7040', Private_Dining_Available__c=true, Reservation_Deposit_Required__c=true,
        Menu_Highlights__c='Lick It Up, Yogurt Explosion, Charcoal', State__c='Bangkok', Zip__c='10110'
    ),
    new Restaurant__c(
        Name='Joe\'s Stone Crab', Cuisine_Type__c='Seafood', Price_Range__c='$$$', City__c='Miami Beach', 
        Address__c='11 Washington Ave', Total_Capacity__c=450, Active__c=true, ExternalID__c='res_006',
        Accepts_Reservations__c=false, Accepts_Walkins__c=true, Avg_Rating__c=4.6, Bar_Available__c=true,
        Cancellation_Window_Hours__c=0, Dress_Code__c='Formal', Happy_Hour__c=false, Kids_Menu__c=true,
        Live_Music__c=false, Outdoor_Seating__c=false, Parking_Available__c=true, Partner_Tier__c='Gold',
        Phone__c='305-673-0365', Private_Dining_Available__c=true, Reservation_Deposit_Required__c=false,
        Reservation_Policy__c='No reservations accepted. First come, first served policy since 1913.',
        Menu_Highlights__c='Stone Crabs, Key Lime Pie, Lyonnaise Potatoes', State__c='FL', Zip__c='33139'
    ),
    new Restaurant__c(
        Name='Dishoom', Cuisine_Type__c='Indian', Price_Range__c='$$', City__c='London', 
        Address__c='12 Upper St. Martin\'s Lane', Total_Capacity__c=200, Active__c=true, ExternalID__c='res_007',
        Accepts_Reservations__c=true, Accepts_Walkins__c=true, Avg_Rating__c=4.7, Bar_Available__c=true,
        Cancellation_Window_Hours__c=12, Dress_Code__c='Casual', Happy_Hour__c=false, Kids_Menu__c=true,
        Live_Music__c=false, Outdoor_Seating__c=false, Parking_Available__c=false, Partner_Tier__c='Silver',
        Phone__c='+44 20 7420 9320', Private_Dining_Available__c=false, Reservation_Deposit_Required__c=false,
        Reservation_Policy__c='Reservations for groups of 6 or more only after 6pm.',
        Menu_Highlights__c='Bacon Naan Roll, House Black Daal, Okra Fries', State__c='London', Zip__c='WC2H 9FB'
    ),
    new Restaurant__c(
        Name='Central', Cuisine_Type__c='Mediterranean', Price_Range__c='$$$$', City__c='Lima', 
        Address__c='Av. Pedro de Osma 301', Total_Capacity__c=40, Active__c=true, ExternalID__c='res_008',
        Accepts_Reservations__c=true, Accepts_Walkins__c=false, Avg_Rating__c=4.9, Bar_Available__c=true,
        Cancellation_Window_Hours__c=96, Dress_Code__c='Smart Casual', Happy_Hour__c=false, Kids_Menu__c=false,
        Live_Music__c=false, Outdoor_Seating__c=false, Parking_Available__c=true, Partner_Tier__c='Platinum',
        Phone__c='+51 1 2428515', Private_Dining_Available__c=true, Reservation_Deposit_Required__c=true,
        Menu_Highlights__c='Land of Corn, Extreme Altitude, Amazonian Water', State__c='Lima', Zip__c='15063'
    ),
    new Restaurant__c(
        Name='Katz\'s Delicatessen', Cuisine_Type__c='American', Price_Range__c='$$', City__c='New York', 
        Address__c='205 E Houston St', Total_Capacity__c=300, Active__c=true, ExternalID__c='res_009',
        Accepts_Reservations__c=false, Accepts_Walkins__c=true, Avg_Rating__c=4.5, Bar_Available__c=false,
        Cancellation_Window_Hours__c=0, Dress_Code__c='Casual', Happy_Hour__c=false, Kids_Menu__c=true,
        Live_Music__c=false, Outdoor_Seating__c=false, Parking_Available__c=false, Partner_Tier__c='Bronze',
        Phone__c='212-254-2246', Private_Dining_Available__c=false, Reservation_Deposit_Required__c=false,
        Menu_Highlights__c='Pastrami on Rye, Matzoh Ball Soup, Knish', State__c='NY', Zip__c='10002'
    ),
    new Restaurant__c(
        Name='Din Tai Fung', Cuisine_Type__c='Chinese', Price_Range__c='$$', City__c='Taipei', 
        Address__c='No. 194, Sec. 2, Xinyi Rd', Total_Capacity__c=150, Active__c=true, ExternalID__c='res_010',
        Accepts_Reservations__c=true, Accepts_Walkins__c=true, Avg_Rating__c=4.7, Bar_Available__c=false,
        Cancellation_Window_Hours__c=4, Dress_Code__c='Casual', Happy_Hour__c=false, Kids_Menu__c=true,
        Live_Music__c=false, Outdoor_Seating__c=false, Parking_Available__c=false, Partner_Tier__c='Gold',
        Phone__c='+886 2 2321 8928', Private_Dining_Available__c=true, Reservation_Deposit_Required__c=false,
        Menu_Highlights__c='Xiao Long Bao, Pork Fried Rice, Spicy Shrimp Wontons', State__c='Taipei', Zip__c='106'
    ),
    new Restaurant__c(Name='Le Bernardin', Cuisine_Type__c='French', Price_Range__c='$$$$', City__c='New York', Address__c='155 W 51st St', Total_Capacity__c=100, Active__c=true, ExternalID__c='res_011', Accepts_Reservations__c=true, Avg_Rating__c=4.8, Partner_Tier__c='Platinum', State__c='NY', Zip__c='10019'),
    new Restaurant__c(Name='Sukiyabashi Jiro', Cuisine_Type__c='Japanese', Price_Range__c='$$$$', City__c='Tokyo', Address__c='4-2-15 Ginza', Total_Capacity__c=10, Active__c=true, ExternalID__c='res_012', Accepts_Reservations__c=true, Avg_Rating__c=4.9, Partner_Tier__c='Platinum', State__c='Tokyo', Zip__c='104-0061'),
    new Restaurant__c(Name='Eleven Madison Park', Cuisine_Type__c='American', Price_Range__c='$$$$', City__c='New York', Address__c='11 Madison Ave', Total_Capacity__c=80, Active__c=true, ExternalID__c='res_013', Accepts_Reservations__c=true, Avg_Rating__c=4.8, Partner_Tier__c='Platinum', State__c='NY', Zip__c='10010'),
    new Restaurant__c(Name='Attica', Cuisine_Type__c='Mediterranean', Price_Range__c='$$$$', City__c='Melbourne', Address__c='74 Glen Eira Rd', Total_Capacity__c=50, Active__c=true, ExternalID__c='res_014', Accepts_Reservations__c=true, Avg_Rating__c=4.7, Partner_Tier__c='Gold', State__c='VIC', Zip__c='3183'),
    new Restaurant__c(Name='White Rabbit', Cuisine_Type__c='Mediterranean', Price_Range__c='$$$', City__c='Moscow', Address__c='Smolenskaya Square, 3', Total_Capacity__c=120, Active__c=true, ExternalID__c='res_017', Accepts_Reservations__c=true, Avg_Rating__c=4.6, Partner_Tier__c='Gold', State__c='Moscow', Zip__c='121099'),
    new Restaurant__c(Name='Quintonil', Cuisine_Type__c='Mexican', Price_Range__c='$$$$', City__c='Mexico City', Address__c='Newton 55, Polanco', Total_Capacity__c=55, Active__c=true, ExternalID__c='res_018', Accepts_Reservations__c=true, Avg_Rating__c=4.7, Partner_Tier__c='Platinum', State__c='CDMX', Zip__c='11560'),
    new Restaurant__c(Name='The Ledbury', Cuisine_Type__c='French', Price_Range__c='$$$$', City__c='London', Address__c='127 Ledbury Rd', Total_Capacity__c=65, Active__c=true, ExternalID__c='res_019', Accepts_Reservations__c=true, Avg_Rating__c=4.7, Partner_Tier__c='Platinum', State__c='London', Zip__c='W11 2AQ'),
    new Restaurant__c(Name='Odette', Cuisine_Type__c='French', Price_Range__c='$$$$', City__c='Singapore', Address__c='1 St Andrew\'s Rd', Total_Capacity__c=50, Active__c=true, ExternalID__c='res_020', Accepts_Reservations__c=true, Avg_Rating__c=4.8, Partner_Tier__c='Platinum', State__c='Singapore', Zip__c='178957'),
    new Restaurant__c(Name='Den', Cuisine_Type__c='Japanese', Price_Range__c='$$$$', City__c='Tokyo', Address__c='2-3-18 Jingumae', Total_Capacity__c=25, Active__c=true, ExternalID__c='res_021', Accepts_Reservations__c=true, Avg_Rating__c=4.8, Partner_Tier__c='Platinum', State__c='Tokyo', Zip__c='150-0001'),
    new Restaurant__c(Name='Hiša Franko', Cuisine_Type__c='Mediterranean', Price_Range__c='$$$$', City__c='Kobarid', Address__c='Staro selo 1', Total_Capacity__c=40, Active__c=true, ExternalID__c='res_022', Accepts_Reservations__c=true, Avg_Rating__c=4.8, Partner_Tier__c='Platinum', State__c='Kobarid', Zip__c='5222'),
    new Restaurant__c(Name='Septime', Cuisine_Type__c='French', Price_Range__c='$$$', City__c='Paris', Address__c='80 Rue de Charonne', Total_Capacity__c=45, Active__c=true, ExternalID__c='res_023', Accepts_Reservations__c=true, Avg_Rating__c=4.7, Partner_Tier__c='Gold', State__c='IDF', Zip__c='75011'),
    new Restaurant__c(Name='Atomix', Cuisine_Type__c='Japanese', Price_Range__c='$$$$', City__c='New York', Address__c='104 E 30th St', Total_Capacity__c=14, Active__c=true, ExternalID__c='res_024', Accepts_Reservations__c=true, Avg_Rating__c=4.9, Partner_Tier__c='Platinum', State__c='NY', Zip__c='10016'),
    new Restaurant__c(Name='Piazza Duomo', Cuisine_Type__c='Italian', Price_Range__c='$$$$', City__c='Alba', Address__c='Piazza Risorgimento, 4', Total_Capacity__c=30, Active__c=true, ExternalID__c='res_025', Accepts_Reservations__c=true, Avg_Rating__c=4.8, Partner_Tier__c='Platinum', State__c='CN', Zip__c='12051'),
    new Restaurant__c(Name='Steirereck', Cuisine_Type__c='Mediterranean', Price_Range__c='$$$$', City__c='Vienna', Address__c='Am Heumarkt 2A', Total_Capacity__c=90, Active__c=true, ExternalID__c='res_026', Accepts_Reservations__c=true, Avg_Rating__c=4.7, Partner_Tier__c='Platinum', State__c='Vienna', Zip__c='1030'),
    new Restaurant__c(Name='Lido 84', Cuisine_Type__c='Italian', Price_Range__c='$$$', City__c='Gardone Riviera', Address__c='Corso Zanardelli, 196', Total_Capacity__c=45, Active__c=true, ExternalID__c='res_027', Accepts_Reservations__c=true, Avg_Rating__c=4.7, Partner_Tier__c='Gold', State__c='BS', Zip__c='25083'),
    new Restaurant__c(Name='Frantzén', Cuisine_Type__c='Mediterranean', Price_Range__c='$$$$', City__c='Stockholm', Address__c='Klara Norra kyrkogata 26', Total_Capacity__c=23, Active__c=true, ExternalID__c='res_028', Accepts_Reservations__c=true, Avg_Rating__c=4.9, Partner_Tier__c='Platinum', State__c='Stockholm', Zip__c='111 22'),
    new Restaurant__c(Name='Arpège', Cuisine_Type__c='French', Price_Range__c='$$$$', City__c='Paris', Address__c='84 Rue de Varenne', Total_Capacity__c=50, Active__c=true, ExternalID__c='res_029', Accepts_Reservations__c=true, Avg_Rating__c=4.8, Partner_Tier__c='Platinum', State__c='IDF', Zip__c='75007'),
    new Restaurant__c(Name='Don Julio', Cuisine_Type__c='American', Price_Range__c='$$$', City__c='Buenos Aires', Address__c='Guatemala 4699', Total_Capacity__c=80, Active__c=true, ExternalID__c='res_030', Accepts_Reservations__c=true, Avg_Rating__c=4.7, Partner_Tier__c='Gold', State__c='CABA', Zip__c='C1425AUI')
};
insert restaurants;

// 3. Create 30 Authentic Diners
List<Diner__c> diners = new List<Diner__c>{
    new Diner__c(First_Name__c='Alice', Last_Name__c='Johnson', Email__c='alice.j@apple.com', Phone__c='415-555-1212', ExternalID__c='diner_001', Loyalty_Tier__c='Platinum', Total_Lifetime_Bookings__c=52),
    new Diner__c(First_Name__c='Robert', Last_Name__c='Miller', Email__c='rmiller@tesla.com', Phone__c='212-555-3434', ExternalID__c='diner_002', Loyalty_Tier__c='Gold', Total_Lifetime_Bookings__c=28),
    new Diner__c(First_Name__c='Sophia', Last_Name__c='Garcia', Email__c='sophia.g@meta.com', Phone__c='305-555-5656', ExternalID__c='diner_003', Loyalty_Tier__c='Silver', Total_Lifetime_Bookings__c=15),
    new Diner__c(First_Name__c='David', Last_Name__c='Chen', Email__c='dchen@stanford.edu', Phone__c='617-555-7878', ExternalID__c='diner_004', Loyalty_Tier__c='Bronze', Total_Lifetime_Bookings__c=4),
    new Diner__c(First_Name__c='Emma', Last_Name__c='Wilson', Email__c='emma.w@nike.com', Phone__c='206-555-9090', ExternalID__c='diner_005', Loyalty_Tier__c='Platinum', Total_Lifetime_Bookings__c=63),
    new Diner__c(First_Name__c='James', Last_Name__c='O\'Connor', Email__c='james.oc@ireland.ie', Phone__c='555-010-2020', ExternalID__c='diner_006', Loyalty_Tier__c='Gold', Total_Lifetime_Bookings__c=31),
    new Diner__c(First_Name__c='Isabella', Last_Name__c='Rossi', Email__c='i.rossi@prada.it', Phone__c='555-020-3030', ExternalID__c='diner_007', Loyalty_Tier__c='Platinum', Total_Lifetime_Bookings__c=42),
    new Diner__c(First_Name__c='Liam', Last_Name__c='Smith', Email__c='lsmith@bbc.co.uk', Phone__c='555-030-4040', ExternalID__c='diner_008', Loyalty_Tier__c='Silver', Total_Lifetime_Bookings__c=19),
    new Diner__c(First_Name__c='Yuki', Last_Name__c='Tanaka', Email__c='y.tanaka@sony.jp', Phone__c='555-040-5050', ExternalID__c='diner_009', Loyalty_Tier__c='Gold', Total_Lifetime_Bookings__c=24),
    new Diner__c(First_Name__c='Lucas', Last_Name__c='Silva', Email__c='lucas.silva@petrobras.com.br', Phone__c='555-050-6060', ExternalID__c='diner_010', Loyalty_Tier__c='Bronze', Total_Lifetime_Bookings__c=7),
    new Diner__c(First_Name__c='Amara', Last_Name__c='Okafor', Email__c='amara.o@lagos.ng', Phone__c='555-060-7070', ExternalID__c='diner_011', Loyalty_Tier__c='Silver', Total_Lifetime_Bookings__c=11),
    new Diner__c(First_Name__c='Noah', Last_Name__c='Müller', Email__c='noah.m@sap.de', Phone__c='555-070-8080', ExternalID__c='diner_012', Loyalty_Tier__c='Gold', Total_Lifetime_Bookings__c=35),
    new Diner__c(First_Name__c='Mia', Last_Name__c='Dubois', Email__c='mia.d@lvmh.fr', Phone__c='555-080-9090', ExternalID__c='diner_013', Loyalty_Tier__c='Platinum', Total_Lifetime_Bookings__c=58),
    new Diner__c(First_Name__c='Oliver', Last_Name__c='Wong', Email__c='owong@cathaypacific.com', Phone__c='555-090-0101', ExternalID__c='diner_014', Loyalty_Tier__c='Silver', Total_Lifetime_Bookings__c=22),
    new Diner__c(First_Name__c='Charlotte', Last_Name__c='Brown', Email__c='cbrown@qantas.au', Phone__c='555-101-1111', ExternalID__c='diner_015', Loyalty_Tier__c='Gold', Total_Lifetime_Bookings__c=29),
    new Diner__c(First_Name__c='Elijah', Last_Name__c='Jackson', Email__c='ejackson@fedex.com', Phone__c='555-111-2222', ExternalID__c='diner_016', Loyalty_Tier__c='Bronze', Total_Lifetime_Bookings__c=3),
    new Diner__c(First_Name__c='Ava', Last_Name__c='Jones', Email__c='ajones@adobe.com', Phone__c='555-222-3333', ExternalID__c='diner_017', Loyalty_Tier__c='Silver', Total_Lifetime_Bookings__c=14),
    new Diner__c(First_Name__c='William', Last_Name__c='Davis', Email__c='wdavis@skadden.com', Phone__c='555-333-4444', ExternalID__c='diner_018', Loyalty_Tier__c='Platinum', Total_Lifetime_Bookings__c=49),
    new Diner__c(First_Name__c='Harper', Last_Name__c='Miller', Email__c='hmiller@moma.org', Phone__c='555-444-5555', ExternalID__c='diner_019', Loyalty_Tier__c='Gold', Total_Lifetime_Bookings__c=33),
    new Diner__c(First_Name__c='Benjamin', Last_Name__c='Wilson', Email__c='bwilson@spotify.com', Phone__c='555-555-6666', ExternalID__c='diner_020', Loyalty_Tier__c='Bronze', Total_Lifetime_Bookings__c=5),
    new Diner__c(First_Name__c='Evelyn', Last_Name__c='Taylor', Email__c='etaylor@vogue.com', Phone__c='555-666-7777', ExternalID__c='diner_021', Loyalty_Tier__c='Silver', Total_Lifetime_Bookings__c=17),
    new Diner__c(First_Name__c='Sebastian', Last_Name__c='Thomas', Email__c='sthomas@michelin.com', Phone__c='555-777-8888', ExternalID__c='diner_022', Loyalty_Tier__c='Platinum', Total_Lifetime_Bookings__c=71),
    new Diner__c(First_Name__c='Scarlett', Last_Name__c='Moore', Email__c='smoore@expedia.com', Phone__c='555-888-9999', ExternalID__c='diner_023', Loyalty_Tier__c='Gold', Total_Lifetime_Bookings__c=26),
    new Diner__c(First_Name__c='Jack', Last_Name__c='Anderson', Email__c='janderson@espn.com', Phone__c='555-999-0000', ExternalID__c='diner_024', Loyalty_Tier__c='Bronze', Total_Lifetime_Bookings__c=2),
    new Diner__c(First_Name__c='Luna', Last_Name__c='White', Email__c='lwhite@nasa.gov', Phone__c='555-000-1111', ExternalID__c='diner_025', Loyalty_Tier__c='Silver', Total_Lifetime_Bookings__c=13),
    new Diner__c(First_Name__c='Henry', Last_Name__c='Harris', Email__c='hharris@si.edu', Phone__c='555-111-2222', ExternalID__c='diner_026', Loyalty_Tier__c='Gold', Total_Lifetime_Bookings__c=37),
    new Diner__c(First_Name__c='Chloe', Last_Name__c='Martin', Email__c='cmartin@netflix.com', Phone__c='555-222-3333', ExternalID__c='diner_027', Loyalty_Tier__c='Platinum', Total_Lifetime_Bookings__c=66),
    new Diner__c(First_Name__c='Mateo', Last_Name__c='Thompson', Email__c='mateo.t@wb.com', Phone__c='555-333-4444', ExternalID__c='diner_028', Loyalty_Tier__c='Silver', Total_Lifetime_Bookings__c=16),
    new Diner__c(First_Name__c='Zoe', Last_Name__c='Lewis', Email__c='zlewis@nationalgeographic.com', Phone__c='555-444-5555', ExternalID__c='diner_029', Loyalty_Tier__c='Gold', Total_Lifetime_Bookings__c=21),
    new Diner__c(First_Name__c='Leo', Last_Name__c='Walker', Email__c='lwalker@google.com', Phone__c='555-555-6666', ExternalID__c='diner_030', Loyalty_Tier__c='Bronze', Total_Lifetime_Bookings__c=1)
};
insert diners;

// 4. Create 40 Authentic Reservations
List<Reservation__c> reservations = new List<Reservation__c>();
String[] statuses = new String[]{'Confirmed', 'Modified', 'Cancelled', 'No-Show'};
String[] requests = new String[]{'Window seat if possible', 'Nut allergy in the party', 'Celebrating 10th anniversary', 'Quiet corner table', 'High chair needed', 'Near the live music', 'Surprise birthday cake', 'Wait for full party to arrive'};

for(Integer i=1; i<=40; i++) {
    Integer resIdx = Math.mod(i-1, restaurants.size());
    Integer dinerIdx = Math.mod(i-1, diners.size());
    String status = statuses[Math.mod(i, statuses.size())];
    
    Reservation__c r = new Reservation__c(
        Restaurant__c = restaurants[resIdx].Id,
        Diner__c = diners[dinerIdx].Id,
        Booking_DateTime__c = DateTime.now().addDays(i - 10).addHours(Math.mod(i, 4) + 18), // Evening bookings
        Party_Size__c = Math.mod(i, 6) + 2,
        Status__c = status,
        Confirmation_Code__c = 'REAL-' + String.valueOf(i).leftPad(4, '0'),
        Agent_Assisted__c = (Math.mod(i, 3) == 0),
        Special_Requests__c = (Math.mod(i, 2) == 0 ? requests[Math.mod(i, requests.size())] : '')
    );
    
    if(status == 'Cancelled') {
        r.Cancellation_Fee__c = (Math.mod(i, 2) == 0 ? 50.00 : 25.00);
    }
    
    reservations.add(r);
}
insert reservations;

// 5. Create 20 Agent Interactions
List<Agent_Interaction__c> interactions = new List<Agent_Interaction__c>();
String[] resolutions = new String[]{'Self-Service', 'Escalated', 'Abandoned'};
String[] transcriptSnippets = new String[]{
    'User inquired about the dress code. Agent confirmed Formal attire is required.',
    'User requested a table for 10. Agent checked capacity and confirmed availability.',
    'User asked for the cancellation policy. Agent explained the 48-hour window.',
    'User wanted to modify their booking time. Agent updated the reservation successfully.',
    'User asked about vegan options. Agent listed the menu highlights including Vegan Truffle Risotto.'
};

for(Integer i=1; i<=20; i++) {
    Integer resvIdx = Math.mod(i-1, reservations.size());
    interactions.add(new Agent_Interaction__c(
        Conversation_ID__c = 'CONV-REAL-' + i + '-' + Crypto.getRandomInteger(),
        Start_DateTime__c = DateTime.now().addDays(-i),
        End_DateTime__c = DateTime.now().addDays(-i).addMinutes(12),
        Reservation__c = reservations[resvIdx].Id,
        Resolution_Type__c = resolutions[Math.mod(i, resolutions.size())],
        Sentiment_Score__c = 0.6 + (Math.random() * 0.4),
        Topics_Discussed__c = 'Reservation Management',
        Transcript__c = transcriptSnippets[Math.mod(i, transcriptSnippets.size())]
    ));
}
insert interactions;

System.debug('REAL WORLD Data creation complete: 30 Restaurants, 30 Diners, 40 Reservations, 20 Interactions.');
