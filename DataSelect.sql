-- Longer than 100 mins duration movie
select Name,
       Duration,
       case
           when Duration >= 100 then 'long'
           else 'short'
           end as Bytime
from Movie

-- How many actors
select distinct Movie.Name,
                count(MI.ActorID) over (partition by Movie.Name) [HowManyActors],
                stuff((select ', ' + Actor.name
                       from Actor
                                join MovieIn MI on Actor.ActorID = MI.ActorID
                       where MI.MovieID = Movie.MovieID
                       for xml path('')), 1, 1, '')              [Actors]
from Movie
         join MovieIn MI on Movie.MovieID = MI.MovieID
group by Movie.Name, Movie.MovieID, MI.ActorID
order by HowManyActors desc

-- How many managers they have
select count(case when FName = 'Manager' then 1 end)                         [Managers],
       count(case when CustomerID <= 1000 and FName != 'Manager' then 1 end) [Employees],
       count(case when CustomerID >= 1001 then 1 end)                        [Customers]
from Customer

-- How many times ordered by onsite with total price
select case when P.ByCard = 1 then 'Card' else 'Cash' end [Onsite],
       count(OrderID)                                     [Times],
       sum(TotalPrice)                                    [TotalPay],
       avg([Order].TotalPrice)                            [Average]
from [Order]
         join Payment P on P.PaymentID = [Order].PaymentID
where P.Online = 0
group by P.ByCard

-- how many tickets available by date
select Date, count(T.IsAvailable) [TotalTickets], count(case when T.IsAvailable = 1 then 1 end) [AvailableTickets]
from Schedule
         join Screening S on S.ScreeningID = Schedule.ScreeningID
         join Ticket T on S.ScreeningID = T.ScreeningID
where Date > getdate()
group by Date

-- How much did they pay
select Email, FName, sum(TotalPrice) as HowMuch
from Customer
         join Payment P on Customer.CustomerID = P.CustomerID
         join [Order] O on P.PaymentID = O.PaymentID
where Customer.CustomerID != 0
group by Email, FName

-- Payment ranking at least 10
select row_number() over (order by sum(TotalPrice) desc) [Ranking], Email, FName, sum(TotalPrice) [Total]
from Customer
         join Payment P on Customer.CustomerID = P.CustomerID
         join [Order] O on P.PaymentID = O.PaymentID
where Customer.CustomerID != 0
group by Email, FName
having sum(TotalPrice) >= 10


-- MovieID and Movie list
select MovieID, Name
from Movie
order by Name

-- Movie category list
select CategoryID, name
from Category
order by CategoryID

-- Movie's information by movie
select Movie.Name,
       Movie.year,
       Movie.Director,
       Movie.Country,
       Movie.Duration,
       Movie.PremDate,
       Movie.RemDate,
       C.Name [Category]
from Movie
         join Category C on C.CategoryID = Movie.CategoryID
where Movie.MovieID = 3

-- Available Movie by date
select S.Date, T.Time, M.Name
from Screening
         join Movie M on M.MovieID = Screening.MovieID
         join Schedule S on Screening.ScreeningID = S.ScreeningID
         join Time T on T.TimeID = Screening.TimeID
where Screening.IsAvailable = 1

-- Available Movie by time in a day
select S.Date, T.Time, M.Name
from Screening
         join Movie M on M.MovieID = Screening.MovieID
         join Schedule S on Screening.ScreeningID = S.ScreeningID
         join Time T on T.TimeID = Screening.TimeID
where Screening.IsAvailable = 1
  and S.Date = '2021/05/23'

-- Movie's information by movie
select Movie.Name,
       Movie.year,
       Movie.Director,
       Movie.Country,
       Movie.Duration,
       Movie.PremDate,
       Movie.RemDate,
       C.Name                              [Category],
       STUFF((SELECT ', ' + Actor.name
              FROM Actor
                       join MovieIn MI on Actor.ActorID = MI.ActorID
              WHERE MI.MovieID = Movie.MovieID
              FOR XML PATH('')), 1, 1, '') [Actors]
from Movie
         join Category C on C.CategoryID = Movie.CategoryID
where Movie.Name = 'Parasite'
-- where Movie.MovieID = 7

-- Whole schedule
select A.AuditoriumID, M.Name, Schedule.Date, T.Time
from Schedule
         join Auditorium A on A.AuditoriumID = Schedule.AuditoriumID
         join Screening S on S.ScreeningID = Schedule.ScreeningID
         join Movie M on M.MovieID = S.MovieID
         join Time T on T.TimeID = S.TimeID

-- Schedule by Movie
select A.AuditoriumID, Movie.name, S2.Date, T.Time
from Movie
         join Screening S on Movie.MovieID = S.MovieID
         join Schedule S2 on S.ScreeningID = S2.ScreeningID
         join Time T on S.TimeID = T.TimeID
         join Auditorium A on A.AuditoriumID = S2.AuditoriumID
where Movie.Name = 'Avengers: Endgame'
   or Movie.Name = 'Parasite'

-- Customer list with information
select CustomerID, FName, LName, Phone, Email
from Customer
order by FName

-- Total order list
select Customer.CustomerID, O.OrderID, O.Date, O.Amount, O.TotalPrice
from Customer
         join Payment P on Customer.CustomerID = P.CustomerID
         join [Order] O on P.PaymentID = O.PaymentID

-- Total order list by customer
select Customer.CustomerID, Customer.Email, O.OrderID, O.Date, O.Amount, O.TotalPrice
from Customer
         join Payment P on Customer.CustomerID = P.CustomerID
         join [Order] O on P.PaymentID = O.PaymentID
where Customer.CustomerID = 1003

-- Receipt by orderID
select Payment.ByCard, Payment.Online, O.Date, O.Amount, O.TotalPrice
from Payment
         join [Order] O on Payment.PaymentID = O.PaymentID
where O.OrderID = 11

-- Available ticket by date and time
select M.Name, S2.Date, T.Time, Ticket.SeatID
from Ticket
         join Screening S on S.ScreeningID = Ticket.ScreeningID
         join Time T on T.TimeID = S.TimeID
         join Schedule S2 on S.ScreeningID = S2.ScreeningID
         join Movie M on M.MovieID = S.MovieID
where Ticket.IsAvailable = 1
  and S2.date = '2021/05/20'
--   and T.Time = '09:00'
  and T.TimeID = 1

-- Ticket information by orderID
select M.Name, S2.Date, T2.Time, S3.AuditoriumID, S3.RowNum, S3.ColNum
from [Order]
         join Ticket T on [Order].OrderID = T.OrderID
         join Screening S on S.ScreeningID = T.ScreeningID
         join Schedule S2 on S.ScreeningID = S2.ScreeningID
         join Time T2 on T2.TimeID = S.TimeID
         join Movie M on M.MovieID = S.MovieID
         join Seat S3 on S3.SeatID = T.SeatID
where [Order].OrderID = 11