@isTest
private class FilterTest
{
    /////////////////////////////////////////////////////////////////
    // standard filter types
    /////////////////////////////////////////////////////////////////

    private static testMethod void testFieldChangedFilter()
    {
        Test.startTest();

            Filter companyChangedFilter = Filter.fieldChanged( Lead.Company );

        Test.stopTest();

        System.assert( companyChangedFilter.predicate instanceof Filter.FieldChangedPredicate,
            'The field changed filter should have a predicate of the Field Changed variety' );

        Filter.FieldChangedPredicate predicate = (Filter.FieldChangedPredicate)companyChangedFilter.predicate;
        System.assertEquals( predicate.field, Lead.Company,
            'The field passed in should be the filter field' );
    }

    private static testMethod void testFieldNullFilter()
    {
        Test.startTest();

            Filter companyNullFilter = Filter.fieldNull( Lead.Company );

        Test.stopTest();

        System.assert( companyNullFilter.predicate instanceof Filter.FieldNullPredicate,
            'The field changed filter should have a predicate of the Field Changed variety' );

        Filter.FieldNullPredicate predicate = (Filter.FieldNullPredicate)companyNullFilter.predicate;
        System.assertEquals( predicate.field, Lead.Company,
            'The field passed in should be the filter field' );
    }

    /////////////////////////////////////////////////////////////////
    // Filter instance methods
    /////////////////////////////////////////////////////////////////

    private static testMethod void testFilter_Insert()
    {
        final Integer NUM_MATCHING = 6;
        final Integer MOD_FACTOR = 3;
        final Integer NUM_RECORDS = NUM_MATCHING * MOD_FACTOR;
        final String FILTER_COMPANY = 'Foobar Industries';

        Filter filter = new Filter( new CompanyMatcher( FILTER_COMPANY ) );

        List<sObject> testRecords = new List<sObject>();

        for ( Integer i = 0; i < NUM_RECORDS; i++ )
        {
            if ( Math.mod( i, MOD_FACTOR ) == 0 )
            {
                testRecords.add( new Lead( Company = FILTER_COMPANY ) );
            }
            else
            {
                testRecords.add( new Lead( Company = 'Intractable Industries' ) );
            }
        }

        Test.startTest();

            List<sObject> filteredRecords = filter.filter( testRecords );

        Test.stopTest();

        System.assertEquals( NUM_MATCHING, filteredRecords.size(),
            'All records matching the filter should be returned' );

        for ( sObject record : filteredRecords )
        {
            System.assertEquals( FILTER_COMPANY, record.get('Company'),
                'Only records matching the filter should be returned' );
        }
    }

    private static testMethod void testFilter_Update()
    {
        final Integer NUM_MATCHING = 6;
        final Integer MOD_FACTOR = 3;
        final Integer NUM_RECORDS = NUM_MATCHING * MOD_FACTOR;
        final String FILTER_COMPANY = 'Foobar Industries';

        Filter filter = new Filter( new CompanyMatcher( FILTER_COMPANY ) );

        List<sObject> testRecords = new List<sObject>();

        for ( Integer i = 0; i < NUM_RECORDS; i++ )
        {
            Lead testRecord = new Lead();
            testRecord.FirstName = 'John';
            testRecord.LastName = 'Resig';

            if ( Math.mod( i, MOD_FACTOR ) == 0 )
            {
                testRecord.Company = 'Intractable Industries';
            }
            else
            {
                testRecord.Company = FILTER_COMPANY;
            }

            testRecords.add( testRecord );
        }

        insert testRecords;

        Map<Id, sObject> oldRecords = new Map<Id, sObject>( (List<Lead>)testRecords.clone() );

        Test.startTest();

            List<sObject> filteredRecords = filter.filter( testRecords, oldRecords );

        Test.stopTest();

        System.assertEquals( NUM_MATCHING, filteredRecords.size(),
            'All records matching the filter should be returned' );

        for ( sObject record : filteredRecords )
        {
            System.assertNotEquals( FILTER_COMPANY, record.get('Company'),
                'Only records matching the filter should be returned' );
        }
    }

    /////////////////////////////////////////////////////////////////
    // standard Predicates
    /////////////////////////////////////////////////////////////////

    private static testMethod void testPredicate_FieldChanged_Insert()
    {
        Filter.Predicate predicate = new Filter.FieldChangedPredicate( Lead.Company );

        sObject sObjectWithValue = new Lead();
        sObjectWithValue.put( 'Company', 'Foobar Industries' );

        sObject sObjectWithoutValue = new Lead();

        Test.startTest();

            Boolean fieldWithValueChanged = predicate.evaluate( sObjectWithValue );
            Boolean fieldWithoutValueChanged = predicate.evaluate( sObjectWithoutValue );

        Test.stopTest();

        System.assertEquals( true, fieldWithValueChanged,
            'A Field with a value on insert is considered changed' );
        System.assertEquals( false, fieldWithoutValueChanged,
            'A Field without a value on insert isn\'t considered changed' );
    }

    private static testMethod void testPredicate_FieldChanged_Update()
    {
        Filter.Predicate predicate = new Filter.FieldChangedPredicate( Lead.Company );

        sObject sObjectOriginal = new Lead();
        sObjectOriginal.put( 'Company', 'Foobar Industries' );

        sObject sObjectWithOldValue = new Lead();
        sObjectWithOldValue.put( 'Company', 'Foobar Industries' );

        sObject sObjectWithNewValue = new Lead();
        sObjectWithNewValue.put( 'Company', 'Intractable Industries' );

        Test.startTest();

            Boolean fieldWithOldValueChanged = predicate.evaluate( sObjectWithOldValue, sObjectOriginal );
            Boolean fieldWithNewValueChanged = predicate.evaluate( sObjectWithNewValue, sObjectOriginal );

        Test.stopTest();

        System.assertEquals( false, fieldWithOldValueChanged,
            'A Field with the original value on update isn\'t considered changed' );
        System.assertEquals( true, fieldWithNewValueChanged,
            'A Field with a new value on update isn\'t considered changed' );
    }

    private static testMethod void testPredicate_FieldNull_Insert()
    {
        Filter.Predicate predicate = new Filter.FieldNullPredicate( Lead.Company );

        sObject sObjectWithValue = new Lead();
        sObjectWithValue.put( 'Company', 'Foobar Industries' );

        sObject sObjectWithoutValue = new Lead();

        Test.startTest();

            Boolean fieldWithValueNull = predicate.evaluate( sObjectWithValue );
            Boolean fieldWithoutValueNull = predicate.evaluate( sObjectWithoutValue );

        Test.stopTest();

        System.assertEquals( false, fieldWithValueNull,
            'A Field with a value on insert is not null' );
        System.assertEquals( true, fieldWithoutValueNull,
            'A Field without a value on insert is null' );
    }

    private static testMethod void testPredicate_FieldNull_Update()
    {
        Filter.Predicate predicate = new Filter.FieldNullPredicate( Lead.Company );

        sObject sObjectOriginal = new Lead();
        sObjectOriginal.put( 'Company', 'Foobar Industries' );

        sObject sObjectWithValue = new Lead();
        sObjectWithValue.put( 'Company', 'Foobar Industries' );

        sObject sObjectWithoutValue = new Lead();
        sObjectWithoutValue.put( 'Company', null );

        Test.startTest();

            Boolean fieldWithValueNull = predicate.evaluate( sObjectWithValue, sObjectOriginal );
            Boolean fieldWithoutValueNull = predicate.evaluate( sObjectWithoutValue, sObjectOriginal );

        Test.stopTest();

        System.assertEquals( false, fieldWithValueNull,
            'A Field with a value on update isn\'t null' );
        System.assertEquals( true, fieldWithoutValueNull,
            'A Field without a value on update is null' );
    }

    /////////////////////////////////////////////////////////////////
    // test predicate
    /////////////////////////////////////////////////////////////////

    private class CompanyMatcher implements Filter.Predicate
    {
        String company;
        CompanyMatcher( String company )
        {
            this.company = company;
        }

        public Boolean evaluate( sObject newRecord )
        {
            return newRecord.get('Company') == company;
        }

        public Boolean evaluate( sObject newRecord, sObject oldRecord )
        {
            return newRecord.get('Company') != company;
        }
    }
}