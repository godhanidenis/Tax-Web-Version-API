USE [TMS]
GO
/****** Object:  Table [dbo].[holders]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[holders](
	[holder_id] [int] IDENTITY(1,1) NOT NULL,
	[holder_name] [varchar](100) NULL,
	[holder_email] [varchar](100) NOT NULL,
	[holder_phone] [varchar](10) NULL,
	[holder_status] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[holder_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[holder_email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[holders_groups]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[holders_groups](
	[group_id] [int] IDENTITY(1,1) NOT NULL,
	[owner_id] [int] NULL,
	[group_name] [varchar](100) NULL,
	[group_type] [varchar](10) NULL,
	[group_status] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[holders_groups_members]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[holders_groups_members](
	[group_id] [int] NULL,
	[member_id] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[test]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[test](
	[id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[holders_groups]  WITH CHECK ADD FOREIGN KEY([owner_id])
REFERENCES [dbo].[holders] ([holder_id])
GO
ALTER TABLE [dbo].[holders_groups_members]  WITH CHECK ADD FOREIGN KEY([group_id])
REFERENCES [dbo].[holders_groups] ([group_id])
GO
ALTER TABLE [dbo].[holders_groups_members]  WITH CHECK ADD FOREIGN KEY([member_id])
REFERENCES [dbo].[holders] ([holder_id])
GO
/****** Object:  StoredProcedure [dbo].[add_member]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- exec add_member @group_id=2, @member_id='2'
CREATE PROCEDURE [dbo].[add_member](
	@group_id int,
	@member_id varchar(100)
)
AS
BEGIN
	declare @group_type varchar(10);
	declare @member_copunt varchar(10);

	select @group_type = group_type from dbo.holders_groups where group_id = @group_id;	
	declare @new_owner_name varchar(100);
    declare @new_owner_id int;
	
	IF @group_type = 's' 
	BEGIN
		select @member_copunt = COUNT(value) from string_split(@member_id, ',');

		IF @member_copunt >= 2
		BEGIN
			insert into dbo.holders_groups_members (
				group_id,
				member_id
			) select @group_id, value from string_split(@member_id, ',');

			select 
				Top 1
				@new_owner_name = h.holder_name, 
				@new_owner_id = h.holder_id
			from 
				dbo.holders as h, 
				dbo.holders_groups_members as hgm
			where 
				h.holder_id = hgm.member_id and 
				hgm.group_id = @group_id
			order by h.holder_name;

			update dbo.holders_groups set group_name=@new_owner_name, owner_id=@new_owner_id, group_type='married' where group_id = @group_id;
		END
		ELSE
		BEGIN
			insert into dbo.holders_groups_members (
				group_id,
				member_id
			) select @group_id, value from string_split(@member_id, ',');

			select 
				Top 1
				@new_owner_name = h.holder_name, 
				@new_owner_id = h.holder_id
			from 
				dbo.holders as h, 
				dbo.holders_groups_members as hgm
			where 
				h.holder_id = hgm.member_id and 
				hgm.group_id = @group_id
			order by h.holder_name;			
		
			update dbo.holders_groups set group_name=@new_owner_name, owner_id=@new_owner_id, group_type='single' where group_id = @group_id;
		END
	END
	IF @group_type = 'b' 
	BEGIN		
		insert into dbo.holders_groups_members (
			group_id,
			member_id
		) select @group_id, value from string_split(@member_id, ',');
		
		select 
			Top 1
			@new_owner_name = h.holder_name, 
			@new_owner_id = h.holder_id
		from 
			dbo.holders as h, 
			dbo.holders_groups_members as hgm
		where 
			h.holder_id = hgm.member_id and 
			hgm.group_id = @group_id
		order by h.holder_name;	

		update dbo.holders_groups set owner_id=@new_owner_id, group_type='business' where group_id = @group_id;
	END
	ELSE IF @group_type = 'single'
	BEGIN
		update dbo.holders_groups set group_type='married' where group_id = @group_id;

		insert into dbo.holders_groups_members (
			group_id,
			member_id
		) select @group_id, value from string_split(@member_id, ',');
	END
	ELSE IF @group_type = 'married'
	BEGIN
		update dbo.holders_groups set group_type='married' where group_id = @group_id;

		insert into dbo.holders_groups_members (
			group_id,
			member_id
		) select @group_id, value from string_split(@member_id, ',');
	END
	ELSE IF @group_type = 'business'
	BEGIN
		insert into dbo.holders_groups_members (
			group_id,
			member_id
		) select @group_id, value from string_split(@member_id, ',');
	END

	select 'Member Add Successfully..' as info_message;

	exec list_group @group_id;
END
GO
/****** Object:  StoredProcedure [dbo].[create_business]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec create_business @group_name="tes1t", @member_list='1,2'
CREATE PROCEDURE [dbo].[create_business](
	@group_name varchar(100),  
	@member_list varchar(100)
)
AS
BEGIN
	declare @created_group_id int;
	declare @new_owner_id int;

	insert into dbo.holders_groups (
		owner_id,
		group_name,
		group_type,
		group_status
	) values (
		NULL,
		@group_name,
		'business',
		'active'
	);

	set @created_group_id = (select SCOPE_IDENTITY() as group_id);

	insert into dbo.holders_groups_members (
		group_id,
		member_id
	) select @created_group_id, value from string_split(@member_list, ',');

	select 
        Top 1
        @new_owner_id = h.holder_id
    from 
        dbo.holders as h, 
        dbo.holders_groups_members as hgm
    where 
        h.holder_id = hgm.member_id and 
        hgm.group_id = @created_group_id
    order by h.holder_name;

	update dbo.holders_groups set owner_id = @new_owner_id where group_id = @created_group_id and group_type = 'business';

	select 'Insert Successfully..' as info_message;

	exec list_group @created_group_id;
END
GO
/****** Object:  StoredProcedure [dbo].[create_group]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec create_group @holder_name='Hari', @holder_email='hari@mailinator.com', @holder_phone='1234567890', @group_type='single', @reference_id=0
-- exec create_group @holder_name='Pari', @holder_email='pari@mailinator.com', @holder_phone='2345678901', @group_type='married', @reference_id=1
CREATE PROCEDURE [dbo].[create_group] (
	@holder_name varchar(100), 
	@holder_email varchar(100), 
	@holder_phone varchar(10), 	
	@group_type varchar(10), 
	@reference_id int
)
AS
BEGIN
	declare @created_holder_id int;
	declare @created_group_id int;
	declare @holder_type varchar(10);
	declare @holder_id int;

	BEGIN TRY
		EXEC @created_holder_id = dbo.create_holder @holder_name, @holder_email, @holder_phone;

		IF @group_type = 'single'
		BEGIN
			insert into dbo.holders_groups (
				owner_id,
				group_name,
				group_type,
				group_status
			) values (
				@created_holder_id,
				@holder_name,
				@group_type,
				'active'
			);
		
			set @created_group_id = (select SCOPE_IDENTITY() as group_id);

			insert into dbo.holders_groups_members (
				group_id,
				member_id
			) values (
				@created_group_id,
				@created_holder_id
			);		
		END
		ELSE IF @group_type = 'married'
		BEGIN
			update dbo.holders_groups set group_type = @group_type where group_id = @reference_id;		
			set @created_group_id = @reference_id;
			insert into dbo.holders_groups_members (
				group_id,
				member_id
			) values (
				@reference_id,
				@created_holder_id
			);	
		END
		select 'Insert Successfully..' as info_message;

		exec list_group @created_group_id;
	END TRY
	BEGIN CATCH
		SELECT 'email allready exists' AS info_message; 
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[create_holder]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec create_group @holder_name='Umesh', @holder_email='umesh@mailinator.com', @holder_phone='1234567890'
CREATE PROCEDURE [dbo].[create_holder](
	@holder_name varchar(100),
	@holder_email varchar(100),
	@holder_phone varchar(10)
)
AS
BEGIN
	declare @created_id int;

	insert into dbo.holders (
		holder_name,
		holder_email,
		holder_phone,
		holder_status
	) values (
		@holder_name,
		@holder_email,
		@holder_phone,
		'active'
	);
	set @created_id = (select SCOPE_IDENTITY() as holder_id);
	
	return @created_id;
END
GO
/****** Object:  StoredProcedure [dbo].[delete_member]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec delete_member @group_id=1, @member_id=3
CREATE PROCEDURE [dbo].[delete_member](
    @group_id int,
    @member_id int
)
AS
BEGIN
    declare @group_type varchar(10);
    declare @member_count int;

    declare @new_owner_name varchar(100);
    declare @new_owner_id int;

    delete from dbo.holders_groups_members where group_id = @group_id and member_id = @member_id;    
    
    select @group_type = group_type from dbo.holders_groups where group_id = @group_id;
    
    IF @group_type = 'single'
    BEGIN
        update dbo.holders_groups set group_type = 's', owner_id=NULL where group_id = @group_id;
    END
    ELSE IF @group_type = 'married'
    BEGIN
        select 
            Top 1
            @new_owner_name = h.holder_name, 
            @new_owner_id = h.holder_id
        from 
            dbo.holders as h, 
            dbo.holders_groups_members as hgm
        where 
            h.holder_id = hgm.member_id and 
            hgm.group_id = @group_id
        order by h.holder_name;
        
        update dbo.holders_groups set group_type = 'single', group_name = @new_owner_name, owner_id = @new_owner_id where group_id = @group_id;
    END
    ELSE IF @group_type = 'business'
    BEGIN
		
		If (select count(*) from dbo.holders_groups where group_id = @group_id and owner_id = @member_id) != 0
        BEGIN
			select 
				Top 1
				@new_owner_name = h.holder_name, 
				@new_owner_id = h.holder_id
			from 
				dbo.holders as h, 
				dbo.holders_groups_members as hgm
			where 
				h.holder_id = hgm.member_id and 
				hgm.group_id = @group_id
			order by h.holder_name;

			select @member_count = count(*) from dbo.holders_groups_members where group_id = @group_id;
			IF @member_count = 0
			BEGIN
				update dbo.holders_groups set group_type = 'b', owner_id = @new_owner_id where group_id = @group_id;
			END
			ELSE
			BEGIN
				update dbo.holders_groups set owner_id = @new_owner_id where group_id = @group_id;
			END
        END
    END
	select 'Delete Successfully..' as info_message;

	exec list_group @group_id;
END
GO
/****** Object:  StoredProcedure [dbo].[edit_group_status]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec edit_group_status @group_id=1
CREATE PROCEDURE [dbo].[edit_group_status](
	@group_id int
)
AS
BEGIN
	declare @group_status varchar(10);
	
	select @group_status = group_status from dbo.holders_groups where group_id = @group_id;
	
	IF @group_status = 'active'
	BEGIN
		update dbo.holders_groups set group_status = 'archived' where group_id = @group_id;
	END
	ELSE
	BEGIN
		update dbo.holders_groups set group_status = 'active' where group_id = @group_id;
	END
	
	select 'Status Update Successfully' as info_message;

	exec list_group @group_id;
END
GO
/****** Object:  StoredProcedure [dbo].[edit_holder]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec edit_holder @group_id=1, @holder_id=1, @holder_name='Max', @holder_email='max@mailinator.com', @holder_phone='1234567890', @holder_status='active'
CREATE PROCEDURE [dbo].[edit_holder](
	@group_id int,
	@holder_id int,
	@holder_name varchar(100),
	@holder_email varchar(100),
	@holder_phone varchar(10),
	@holder_status varchar(10)
)
AS
BEGIN
	declare @count_check int;
	declare @holder_check int;

	select @holder_check = count(*) from dbo.holders where holder_email = @holder_email and holder_id != @holder_id;
	IF @holder_check = 1
	BEGIN
		SELECT 'email allready exists' AS info_message; 
	END
	ELSE
	BEGIN
		update dbo.holders set 
			holder_name	= @holder_name,
			holder_email = @holder_email,
			holder_phone = @holder_phone,
			holder_status = @holder_status
		where 
			holder_id = @holder_id;
	
		select @count_check = count(*) from dbo.holders_groups where group_id = @group_id and owner_id = @holder_id and group_type != 'business';
	
		IF @count_check = 1
		BEGIN
			update dbo.holders_groups set group_name = @holder_name where group_id = @group_id and owner_id = @holder_id and group_type != 'business';
		END
	
		select 'Update Successfully..' as info_message;
	END

	exec list_group @group_id;
END
GO
/****** Object:  StoredProcedure [dbo].[list_group]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec list_group @group_id=2
CREATE PROCEDURE [dbo].[list_group] (
	@group_id int
)
AS
BEGIN
	IF @group_id != 0
	BEGIN
		select 
			hg.group_id, 
			hg.group_name, 
			h.holder_email, 
			h.holder_phone,
			hg.group_type, 
			hg.group_status, 
			hg.owner_id
		from 
			dbo.holders as h right join
			dbo.holders_groups as hg on		
			hg.owner_id = h.holder_id where 
			hg.group_id = @group_id;

        select 
			h.holder_id, 
			h.holder_name, 
			h.holder_email, 
			h.holder_phone, 
			h.holder_status,
			hgm.group_id
		from 
			dbo.holders_groups_members as hgm, 
			dbo.holders as h 
		where 
			hgm.member_id = h.holder_id and 
			group_id = @group_id;
	END
	ELSE 
	BEGIN
		select 
			hg.group_id, 
			hg.group_name, 
			h.holder_email, 
			h.holder_phone,
			hg.group_type, 
			hg.group_status, 
			hg.owner_id
		from 
			dbo.holders as h right join
			dbo.holders_groups as hg on
			hg.owner_id = h.holder_id;
	END
END
GO
/****** Object:  StoredProcedure [dbo].[list_holder]    Script Date: 9/5/2022 6:01:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec list_holder
CREATE PROCEDURE [dbo].[list_holder]
AS
BEGIN
	select * from dbo.holders;
END
GO

insert into test values (1);