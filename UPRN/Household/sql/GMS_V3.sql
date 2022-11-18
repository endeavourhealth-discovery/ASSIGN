USE [test01]
GO
/****** Object:  UserDefinedFunction [dbo].[GMS_V3]    Script Date: 18/11/2022 14:15:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[GMS_V3](@nor bigint, @event_date date)
RETURNS VARCHAR

BEGIN
	-- declare @event_date as date
	-- declare @nor as bigint
	
	-- set @event_date = '2013-12-01'
	-- set @nor = 7

	declare @var_date_registered as date
	declare @var_date_registered_end as date
	declare @b as varchar(1)

	-- declare @var_date date, @var_dat2 as date = (
	Select top 1 @var_date_registered=latestreg.date_registered, @var_date_registered_end=latestreg.date_registered_end
	From(
	Select top 1000 patient_id, date_registered, date_registered_end, registration_type_concept_id
	From [test01].[dbo].[episode_of_care] e
	join [test01].[dbo].[patient]p on p.id=e.patient_id
	Where (date_registered <= @event_date and e.patient_id = @nor and (p.date_of_death >= @event_date or p.date_of_death is null))
	Order by e.date_registered, e.date_registered_end desc) as latestreg
	Where (latestreg.registration_type_concept_id=1335267) and (latestreg.date_registered_end is null or (latestreg.date_registered_end >= @event_date))

	-- print @var_date_registered
	-- print @var_date_registered_end

	-- 1=Registered and alive, 2=not registered, 3=Unclear
	set @b = case
		when ((@var_date_registered_end < @var_date_registered)) then 3
		when @var_date_registered is not null then 1
		else 2
	end

	return @b
END