USE [test01]
GO
/****** Object:  UserDefinedFunction [dbo].[PlaceAtEventTime_V2_5]    Script Date: 18/11/2022 14:14:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[PlaceAtEventTime_V2_5](@patient_id as bigint, @event_date date)
RETURNS
@tUPRN TABLE
(
	-- multiple_addresses int,
	-- place_of_residence_count int,
	-- address_count int,
	id bigint,
	person_id bigint,
	patient_id bigint,
	patient_address_id bigint,
	gms int,
	address_candidate_count int,
	address_start_date date,
	address_end_date date,
	uprn varchar(255),
	ralf varchar(255),
	address_line_1 varchar(255),
	address_line_2 varchar(255),
	address_line_3 varchar(255),
	address_line_4 varchar(255),
	towncity varchar(100),
	postcode varchar(50),
	lsoa varchar(200),
	msoa varchar(200),
	uprn_match_date datetime,
	uprn_match_qualifier varchar(100),
	epoch int,
	property_classification varchar(50),
	uprn_x float,
	uprn_y float,
	match_pattern_flat varchar(200),
	match_pattern_number varchar(200),
	match_pattern_street varchar(200),
	match_pattern_post_code varchar(200),
	use_concept_id int,
	event_date date,
	reason varchar(200)
)
AS
BEGIN
	DECLARE @gms as varchar(1)
	DECLARE @address_count as int
	DECLARE @place_of_residence_count as int
	DECLARE @person_id as bigint
	DECLARE @notnull as int
	DECLARE @pclass as int
	DECLARE @best int
	DECLARE @tempadrs int
	DECLARE @reason varchar(200)

	select @gms = [dbo].GMS_V3(@patient_id, @event_date)
	-- must be currently registered for event date
	if @gms <> 1 begin
		INSERT INTO @tUPRN(id, person_id, patient_id, patient_address_id, gms, address_candidate_count, event_date)
			VALUES (null, null, @patient_id, null, @gms, null, @event_date)
		RETURN
	end
	
	DECLARE @tQry TABLE
	(
		id bigint, person_id bigint, patient_id bigint,
		patient_address_id bigint, gms int, address_candidate_count int,
		address_start_date date, address_end_date date, uprn varchar(255),
		ralf varchar(255), address_line_1 varchar(255), address_line_2 varchar(255),
		address_line_3 varchar(255), address_line_4 varchar(255), towncity varchar(100),
		postcode varchar(50), lsoa varchar(200), msoa varchar(200), uprn_match_date datetime,
		uprn_match_qualifier varchar(100), epoch int, property_classification varchar(50), uprn_x float,
		uprn_y float, match_pattern_flat varchar(200), match_pattern_number varchar(200),
		match_pattern_street varchar(200), match_pattern_post_code varchar(200), use_concept_id int,
		event_date date
	)

	INSERT INTO @tQry (id, person_id, patient_id, patient_address_id, gms, address_candidate_count, address_start_date, address_end_date, uprn, ralf,
		address_line_1, address_line_2, address_line_3, address_line_4, towncity, postcode, lsoa, msoa, uprn_match_date,
		uprn_match_qualifier, epoch, property_classification, uprn_x, uprn_y, match_pattern_flat, match_pattern_number, match_pattern_street, match_pattern_post_code, use_concept_id, event_date)

	SELECT uprn_id, a.person_id, a.patient_id, address_id, @gms, 0, a.start_date, a.end_date, a.uprn, a.uprn_ralf00, a.address_line_1, a.address_line_2, a.address_line_3, a.address_line_4, a.city, a.postcode,
		a.lsoa_2011_code, a.msoa_2011_code, a.match_date, a.qualifier, a.epoch, a.uprn_property_classification, a.uprn_xcoordinate, a.uprn_ycoordinate, a.match_pattern_flat, a.match_pattern_number,
		a.match_pattern_street, a.match_pattern_postcode, a.use_concept_id, @event_date
	FROM (    

		SELECT
		uprn.id as uprn_id,
		address.person_id,
		address.patient_id,
		address.id as address_id,
		address.start_date,
		address.end_date,
		uprn.uprn,
		uprn.uprn_ralf00,
		address.address_line_1,
		address.address_line_2,
		address.address_line_3,
		address.address_line_4,
		address.city,
		address.postcode,
		address.lsoa_2011_code,
		address.msoa_2011_code,
		uprn.match_date,
		uprn.qualifier,
		uprn.epoch,
		uprn.uprn_property_classification,
		uprn.uprn_xcoordinate,
		uprn.uprn_ycoordinate,
		uprn.match_pattern_flat,
		uprn.match_pattern_number,
		uprn.match_pattern_street,
		uprn.match_pattern_postcode,
		address.use_concept_id,
		Row_number() over (partition by uprn.patient_address_id order by uprn.match_date desc) as row_index
      
		FROM [test01].[dbo].[patient_address] address

		JOIN [test01].[dbo].[patient_address_match] uprn
		ON uprn.patient_address_id= address.id

		WHERE address.patient_id = @patient_id AND
		(address.start_date <= @event_date or address.start_date is null)
		AND (address.end_date >= @event_date or address.end_date is null)

	) a
	WHERE a.row_index = 1

	DECLARE @tResidential TABLE (id INT, code varchar(20))
	insert into @tResidential values(1,'R'),(2,'RD'),(3,'RD01'),(4,'RD02'),(5,'RD03'),(6,'RD04'),(7,'RD06'),(8,'RD07'),(9,'RD10'),(10,'RH02'),(11,'U'),(12,'UC'),(13,'UP'),(14,'X')

	--select @pclass = count(chk.property_classification)
	--from (select property_classification from @tQry where property_classification not in (select code from @tResidential)) as chk
	select @pclass = count(1)
	from @tQry t
	left join @tResidential r ON r.code = t.property_classification
	where r.code IS NULL

	-- select @best = count(chk.uprn_match_qualifier)
	-- from (select uprn_match_qualifier from @tQry where uprn_match_qualifier <> 'Best (residential) match') as chk
	select @best = count(1)
	from @tQry
	where uprn_match_qualifier <> 'Best (residential) match'

	--select @tempadrs = count(chk.use_concept_id)
	--from (select use_concept_id from @tQry where use_concept_id = '1335360') as chk
	select @tempadrs = count(1)
	from @tQry
	where use_concept_id = '1335360'


	delete from @tQry where property_classification not in (select code from @tResidential) or (uprn_match_qualifier <> 'Best (residential) match')
	delete from @tQry where use_concept_id = '1335360' -- Temps

	select @notnull = count(id) from @tQry -- where address_start_date is not null

	if @notnull = 0
	begin
		set @reason = ''
		if @pclass>0 set @reason = CONCAT(@reason, @pclass, ' invalid property classification(s),')
		if @best>0 set @reason = CONCAT(@reason, @best, ' <> Best (residential) match(s),')
		if @tempadrs>0 set @reason = CONCAT(@reason, @tempadrs, 'Temp address record(s)')
		if @reason = '' set @reason = '?'
		INSERT INTO @tUPRN(id, person_id, patient_id, patient_address_id, gms, address_candidate_count, event_date, reason)
			VALUES (null, null, @patient_id, null, @gms, null, @event_date, @reason)
	end

	if @notnull>0
		INSERT INTO @tUPRN (id, person_id, patient_id, patient_address_id, gms, address_candidate_count, address_start_date, address_end_date, uprn, ralf,
			address_line_1, address_line_2, address_line_3, address_line_4, towncity, postcode, lsoa, msoa, uprn_match_date,
			uprn_match_qualifier, epoch, property_classification, uprn_x, uprn_y, match_pattern_flat, match_pattern_number, match_pattern_street, match_pattern_post_code, use_concept_id, event_date)
		SELECT top 1 * FROM @tQry order by address_start_date, patient_address_id desc
		-- SELECT top 1 * FROM @tQry order by patient_address_id, address_start_date desc
		-- select * from @tQry
	
	RETURN
END