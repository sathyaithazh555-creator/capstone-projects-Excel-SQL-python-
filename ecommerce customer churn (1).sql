 -----                 E-COMMERCE CUSTOMER CHURN DATABASE                 -------
 
 
 use ecomm;
 select count(*) from customer_churn;
 select * from customer_churn;
 select churn,count(*) from customer_churn group by churn;
 select distinct cashbackAmount from customer_churn ;
 
 
 set SQL_safe_updates=0;
 
 ----- IMPUTE MEAN ----- 
 
 set @WarehouseToHome_avg = (select avg(WarehouseToHome) from customer_churn) ;
 select @WarehouseToHome_avg;
 
 
 update customer_churn set WarehouseToHome = @WarehouseToHome_avg where WarehouseToHome is null ;
 
  set@HourSpendOnApp_avg  = (select avg(HourSpendOnApp) from customer_churn) ;
 select @HourSpendOnApp_avg;
 
 
 update customer_churn set HourSpendOnApp = @HourSpendOnApp_avg where HourSpendOnApp is null;
 
 
  set @OrderAmountHikeFromlastYear_avg  = (select avg(OrderAmountHikeFromlastYear) from customer_churn) ;
 select @OrderAmountHikeFromlastYear_avg ;
 
 
 update customer_churn set OrderAmountHikeFromlastYear = @OrderAmountHikeFromlastYear_avg where OrderAmountHikeFromlastYear is null;
 
 
 
  set @DaySinceLastOrder_avg = (select avg(DaySinceLastOrder) from customer_churn) ;
 select @DaySinceLastOrder_avg;
 
 
 update customer_churn set DaySinceLastOrder = @DaySinceLastOrder_avg where DaySinceLastOrder is null;
 
 
 
 ------------      IMPUTE MODE        ----------------
 
 select Tenure,count(*) from customer_churn group by Tenure order by count(*) desc limit 1;
 set @Tenure_mode =(select Tenure from customer_churn group by Tenure order by count(*) desc limit 1);
 select @tenure_mode;
 
 update customer_churn set Tenure = @Tenure_mode  where Tenure is null;
  
  select * from customer_churn ;
  
   select CouponUsed,count(*) from customer_churn group by CouponUsed order by count(*) desc limit 1;
  set @CouponUsed_mode =(select CouponUsed from customer_churn group by CouponUsed order by count(*) desc limit 1);
 select @CouponUsed_mode;
 
 update customer_churn set CouponUsed = @CouponUsed_mode  where CouponUsed is null;
  
  select * from customer_churn ;
 
 
 
  select OrderCount,count(*) from customer_churn group by OrderCount order by count(*) desc limit 1;
  set @OrderCount_mode =(select OrderCount from customer_churn group by OrderCount order by count(*) desc limit 1);
 select @OrderCount_mode;
 
 update customer_churn set OrderCount = @OrderCount_mode  where OrderCount is null; 
   select * from customer_churn ; 
   
   
   
   ----------         HANDLING OUTLIERS IN  WarehouseToHome COLUMN        -------------
   
   select * from customer_churn where WarehouseToHome > 100;
   delete from customer_churn where WarehouseToHome > 100 ;
   select count(*) from customer_churn ;
   
    ---------          DEALING WITH INCONSISTENCIES                 ----------------
    
    --------            REPLACING   VALUES                                ----------------
    
	
    
    update customer_churn 
    set PreferredLoginDevice = if(PreferredLoginDevice = 'phone' , 'Mobile_phone' , PreferredLoginDevice);
    select * from customer_churn;
    
  
    update customer_churn 
    set PreferedOrderCat  = if(PreferedOrderCat = 'mobile' , 'Mobile_phone' , PreferedOrderCat);   
     select * from customer_churn;
      
      update customer_churn
      set PreferredPaymentMode  = case
      when PreferredPaymentMode = 'COD' then  'Cash_on_delivery'
      when PreferredPaymentMode  = 'CC'  then  ' Credit_card'
      else PreferredPaymentMode
      end;
      select * from customer_churn;  
      
     
                      --------------- DATA TRANSFORMATION ---------------
                      
                                ----- COLUMN RENAMING--------
                      
  ALTER TABLE  customer_churn
  rename column preferedOrderCat to preferredordercat ;
    ALTER TABLE  customer_churn  
  rename column Hourspendonapp to HoursSpendOnApp;
  
  SELECT * FROM customer_churn;
  
  
                             ---------- ADDING NEW COLUMN -----------------
 ALTER TABLE customer_churn
 add column Complain_Received enum('YES' , 'NO'),
 add column Churn_status enum('Churned' , 'Active');
  
  select * from customer_churn;
  update customer_churn
  set Complain_Received = if (complain =1,'YES' , 'NO'),
  Churn_status = if (churn ='1', 'Churned', 'Active');
  select * from customer_churn;
  
  
  -------------- column dropping---------------
  
  
  
  alter table customer_churn
  drop column churn,
  drop column complain;
  select * from customer_churn;
  
  
  
             --------- DATA EXPLORATION AND ANALYSIS ---------- (total number of customers by churn_ status)
		
        
        
 select Churn_status , count(*) as churn_status_count from customer_churn group by churn_status; 
 
 
 ----------- avg of tenure and total cashback amount of churned customers------------
 
 select avg(Tenure)  AS Average_tenure,sum(CashbackAmount) as total_cashback from customer_churn 
 where churn_status = 'churned';
 
 
 
                   ------------- % of churned customers,complained------------
                   
 
 select Churn_status , CONCAT(ROUND(COUNT(*) / (SELECT COUNT(*) FROM customer_churn )* 100,2),'%')  
 as churn_percentage from customer_churn where complain_Received = 'YES'  GROUP BY Churn_status;
 
  select Churn_status , CONCAT(ROUND(COUNT(*) / (SELECT COUNT(*) FROM customer_churn )* 100,2),'%')  
 as churn_percentage from customer_churn   GROUP BY Churn_status;
 
 select churn_status, count(*) from customer_churn 
 where complain_Received ='YES' group by churn_status;
 
 
 
 ------------ highest no.of churned_customers preffered laptop, Accessory-------------
 select * from customer_churn;
 
 select citytier ,count(*) as churned_count from customer_churn 
 where churn_status ='churned' and preferredordercat = 'Laptop & Accessory'  group by cityTier 
 order by churned_count  desc limit 1;
 select PreferredPaymentMode, count(*) as total_customers from customer_churn where churn_status ='Active'
 group by PreferredPaymentMode  order by total_customers desc limit 1;  
 select * from customer_churn ;
 select  sum(OrderAmountHikeFromlastYear) as total_order_amount_hike 
 from customer_churn where MaritalStatus = 'Married' and preferredordercat ='Mobile_phone' ;
 select round (avg(NumberOfDeviceRegistered) )as avg_no_of_registered from customer_churn
 where  PreferredPaymentMode ='UPI'; 
 select CityTier, count(CustomerID ) as total_customers  from customer_churn 
 group by CityTier order by total_customers desc limit 1;
 select  gender, count(CouponUsed) as highest_couponused from customer_churn 
 group by gender order by highest_couponused desc limit 1;
 
 select * from customer_churn;
 
 select preferredordercat , count(CustomerID) AS Number_of_customers, max(HoursSpendOnApp) as max_hours_sped_on_app 
 from customer_churn  group by preferredordercat;
 select sum(OrderCount)  as total_order_count from customer_churn where PreferredPaymentMode ='credit card'
 and SatisfactionScore = (select max(SatisfactionScore) from customer_churn) ;
 select avg(SatisfactionScore) as avg_satisfaction_score from customer_churn where complain_Received ='YES';
 
 select preferredordercat,CouponUsed  from customer_churn where CouponUsed  > 5 ;
 
select * from customer_churn ;

select  preferredordercat, avg(CashbackAmount) as avg_cashback  from customer_churn group by preferredordercat 
order by avg_cashback desc limit 3;
select PreferredPaymentMode,avg(Tenure) as avg_tenure, sum(OrderCount) as total_orders 
from customer_churn group by PreferredPaymentMode having avg(Tenure)  =10 and sum(OrderCount) >500;

 
 
select case when WarehouseToHome <= 5 then 'very_close_distance'
when WarehouseToHome <=10 then 'close_distance'
when WarehouseToHome <=15 then 'Moderate_distance'
else 'far_distance'
end as distance_category,
churn_status,
count(*) as customer_count  from customer_churn 
group by distance_category,churn_status 
order by distance_category;
select CustomerID, MaritalStatus,CityTier,OrderCount from customer_churn where MaritalStatus = 'married'
 and CityTier = 1 and OrderCount > ( select avg(OrderCount) from customer_churn);
 
create table customer_returns(
ReturnID int primary key ,
CustomerID INT,
Returndate date , 
Refundamount int) ;
Insert into customer_returns ( ReturnID , CustomerID , Returndate , Refundamount) values
(1001,50022, '2023-01-01', 2130),
(1002,50316, '2023-01-23', 2000),
(1003,51099, '2023-02-14', 2290),
(1004,52321, '2023-03-08', 2510),
(1005,52928, '2023-03-20', 3000),
(1006,53749, '2023-04-17', 1740),
(1007,54206, '2023-04-21', 3250),
(1008,54838, '2023-04-30', 1990);
select * from customer_returns;

select c.CustomerID ,
c.Tenure,
c.PreferredLoginDevice,
c.CityTier,
c.WarehouseToHome,
c.PreferredPaymentMode,
c.Gender,
c.HoursSpendOnApp,
c.NumberOfDeviceRegistered,
c.preferredordercat ,
c.SatisfactionScore,  
c.MaritalStatus , 
c.NumberOfAddress ,
c.OrderAmountHikeFromlastYear , 
c.CouponUsed , 
c.OrderCount,  
c.DaySinceLastOrder , 
c.CashbackAmount , 
c.Complain_Received ,
c.Churn_status,
R.ReturnID ,
  
R.Returndate , 
R.Refundamount
FROM customer_churn as c
JOIN customer_returns  as R
ON c.CustomerID  = R.customerID
where c.churn_status ='churned' and c.complain_Received = 'YES';



 
  
  
  
  
 
 
 
 
 
 
 
 
 
 
 
                    
 
 
 
  
  
             
              
              
              
              
  
  
  
                             
  
  
  
  
     
     
   
   
   
   