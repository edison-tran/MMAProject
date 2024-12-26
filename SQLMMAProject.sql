-- Classifying Finish Details into different martial arts
SELECT 
    Winner AS Fighter, 
    COUNT(*) AS TotalWins,
    SUM(CASE 
        WHEN FinishDetails IN ('Keylock', 'Rear Naked Choke', 'Anaconda Choke', 'Kimura', 'Ezekiel Choke', 'Twister', 
                               'Other - Choke', 'Kneebar', 'Guillotine Choke', 'Arm Triangle', 'Triangle Choke', 'Neck Crank',
							   'Ankle Lock', 'North-South Choke', 'Inverted Triangle', 'D''Arce Choke', 'Heel Hook', 'Other - Lock', 
							   'Peruvian Necktie', 'Triangle Armbar', 'Omoplata', 'Von Flue Choke', 'Straight Armbar') THEN 1 
        ELSE 0 
    END) AS BJJWins,
    SUM(CASE 
        WHEN FinishDetails IN ('Punch', 'Elbow', 'Flying Knee', 'Elbows', 'Knees', 'Spinning Back Kick', 'Punches', 
                               'Kicks', 'Kick', 'Spinning Back Fist', 'Spinning Back Elbow') THEN 1 
        ELSE 0 
    END) AS StrikingWins,
    SUM(CASE 
        WHEN FinishDetails IN ('Slam', 'Scarf Hold') THEN 1 
        ELSE 0 
    END) AS WrestlingWins
FROM PortfolioProject..in$
WHERE FinishDetails IS NOT NULL
GROUP BY Winner
ORDER BY TotalWins DESC;

-- Counting the Number of Fighters in their Respective Weight Classes Since 2010
SELECT 
    CASE 
        WHEN WeightClass IN ('Flyweight', 'Bantamweight', 'Featherweight', 'Lightweight', 
                             'Welterweight', 'Middleweight', 'Light Heavyweight', 'Heavyweight') 
        THEN 'Men'
		WHEN WeightClass IN ('Women''s Strawweight', 'Women''s Flyweight', 'Women''s Bantamweight',
							'Women''s Featherweight')
        THEN 'Women'
        ELSE 'Unknown'
    END AS Gender,
    WeightClass,
    COUNT(DISTINCT RedFighter) + COUNT(DISTINCT BlueFighter) AS TotalFighters
FROM PortfolioProject..in$
GROUP BY Gender, WeightClass
ORDER BY Gender, WeightClass;


-- Finding the Fighter with the Most Fights Per Year
WITH YearlyFights AS (
    SELECT 
        YEAR(Date) AS FightYear, 
        RedFighter AS Fighter
    FROM PortfolioProject..in$
    UNION ALL
    SELECT 
        YEAR(Date) AS FightYear, 
        BlueFighter AS Fighter
    FROM PortfolioProject..[in$]
),
FighterCounts AS (
    SELECT 
        FightYear,
        Fighter,
        COUNT(*) AS Fights
    FROM YearlyFights
    GROUP BY FightYear, Fighter
),
RankedFighters AS (
    SELECT 
        FightYear,
        Fighter,
        Fights,
        ROW_NUMBER() OVER (PARTITION BY FightYear ORDER BY Fights DESC) AS FightRank
    FROM FighterCounts
)
SELECT 
    FightYear,
    Fighter,
    Fights
FROM RankedFighters
WHERE FightRank = 1
ORDER BY FightYear;

-- Average Fight Duration/Round Per Weight Class

SELECT 
    WeightClass,
    ROUND(AVG(TotalFightTimeSecs) / 60.0, 2) AS AvgFightDurationMinutes,
    ROUND(AVG(TotalFightTimeSecs) / 300.0, 2) AS AvgRounds
FROM PortfolioProject..[in$]
WHERE TotalFightTimeSecs IS NOT NULL
GROUP BY WeightClass
ORDER BY AvgFightDurationMinutes DESC;

SELECT * 
FROM PortfolioProject..in$

-- Longest Gap Between Fights For a Fighter
WITH FightGaps AS (
    SELECT 
        Fighter,
        Date,
        LAG(Date) OVER (PARTITION BY Fighter ORDER BY Date) AS PreviousFightDate,
        DATEDIFF(DAY, LAG(Date) OVER (PARTITION BY Fighter ORDER BY Date), Date) AS GapInDays
    FROM (
        SELECT RedFighter AS Fighter, Date FROM PortfolioProject..in$
        UNION ALL
        SELECT BlueFighter AS Fighter, Date FROM PortfolioProject..in$
    ) AllFights
)
SELECT TOP 10
    Fighter,
    MAX(GapInDays) AS LongestGapInDays
FROM FightGaps
WHERE GapInDays IS NOT NULL
GROUP BY Fighter
ORDER BY LongestGapInDays DESC


-- Fighters with the Most Octagon Time

WITH FighterFightTimes AS (
    SELECT 
        RedFighter AS Fighter, 
        ROUND(TotalFightTimeSecs / 60, 2) AS FightTimeMinutes
    FROM PortfolioProject..[in$]
    UNION ALL
    SELECT 
        BlueFighter AS Fighter, 
        ROUND(TotalFightTimeSecs / 60, 2) AS FightTimeMinutes
    FROM PortfolioProject..[in$]
)
SELECT TOP 10
    Fighter,
    SUM(FightTimeMinutes) AS TotalFightTimeMinutes
FROM FighterFightTimes
GROUP BY Fighter
ORDER BY TotalFightTimeMinutes DESC;

-- Determining Fighters' Comeback Wins After Losses

WITH Losses AS (
    SELECT 
        CASE 
            WHEN Winner = 'Red' THEN BlueFighter -- Red fighter loses
            ELSE RedFighter -- Blue fighter loses
        END AS Loser,
        Date AS LossDate
    FROM PortfolioProject.dbo.in$
    WHERE Winner IS NOT NULL AND (Winner = 'Red' OR Winner = 'Blue')
),
RankedLosses AS (
    SELECT 
        Loser, 
        LossDate, 
        ROW_NUMBER() OVER (PARTITION BY Loser ORDER BY LossDate DESC) AS LossRank
    FROM Losses
),
NextFights AS (
    SELECT 
        CASE 
            WHEN Winner = 'Red' THEN RedFighter
            ELSE BlueFighter
        END AS Fighter,
        Date AS NextFightDate,
        Winner,
        CASE 
            WHEN (Winner = 'Red' AND RedFighter = (CASE WHEN Winner = 'Red' THEN RedFighter ELSE BlueFighter END)) 
            OR (Winner = 'Blue' AND BlueFighter = (CASE WHEN Winner = 'Red' THEN RedFighter ELSE BlueFighter END)) THEN 'Win'
            ELSE 'Loss'
        END AS FightResult
    FROM PortfolioProject.dbo.in$
    WHERE Winner IS NOT NULL AND (Winner = 'Red' OR Winner = 'Blue')
),
LossWithNextFight AS (
    SELECT TOP 1 WITH TIES
        L.Loser AS Fighter,
        L.LossDate,
        N.NextFightDate,
        N.FightResult
    FROM RankedLosses L
    INNER JOIN NextFights N ON L.Loser = N.Fighter AND N.NextFightDate > L.LossDate
    WHERE L.LossRank = 1
    ORDER BY ROW_NUMBER() OVER (PARTITION BY L.Loser ORDER BY N.NextFightDate)
)
SELECT 
    Fighter, 
    LossDate, 
    NextFightDate, 
    FightResult
FROM LossWithNextFight
ORDER BY LossDate DESC;
