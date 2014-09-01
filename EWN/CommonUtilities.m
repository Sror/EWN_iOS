//
//  CommonUtilities.m
//  EWN
//
//  Created by Jainesh Patel on 5/1/13.
//
//

#import "CommonUtilities.h"
#import "AppDelegate.h"

@implementation CommonUtilities
AppDelegate *appDelegate;
/**-----------------------------------------------------------------
 Function Name  : sharedManager
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Makes this class shared.
 ------------------------------------------------------------------*/

+ (id)sharedManager
{
    static CommonUtilities *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
- (id)init {
    
    if (self = [super init])
    {
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}
/**-----------------------------------------------------------------
 Function Name  : datefromString
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Takes the date as string and returns the date from string.
 ------------------------------------------------------------------*/
- (NSDate*)datefromString:(NSString*)strDate
{
    NSDate *dateOld;
    
    {
        ///format with normal format
        NSDateFormatter *dateFormatOld = [[NSDateFormatter alloc] init];
        [dateFormatOld setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatOld setDateFormat:kstryyyy_MM_dd_T_HH_mm_ss_Z];
        dateOld = [dateFormatOld dateFromString:strDate];
        
        if(!dateOld)
        {
            ///format with milisecond format
            [dateFormatOld setDateFormat:kstryyyy_MM_dd_T_HH_mm_ss_SSS_Z];
            dateOld = [dateFormatOld dateFromString:strDate];
        }
    }
    return dateOld;
}
/**-----------------------------------------------------------------
 Function Name  : formatDateWithTimeDurationFormat
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Takes the date as string and returns the calculated hours ijn string.
 ------------------------------------------------------------------*/

- (NSString *)formatDateWithTimeDurationFormat : (NSString *)strDate
{
    if(strDate && [strDate length]>0)
    {
        ///format with normal format
        NSDateFormatter *dateFormatOld = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatOld setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatOld setDateFormat:kstryyyy_MM_dd_T_HH_mm_ss_Z];
        NSDate *dateOld = [dateFormatOld dateFromString:strDate];
        
        if(!dateOld)
        {
            ///format with milisecond format
            [dateFormatOld setDateFormat:kstryyyy_MM_dd_T_HH_mm_ss_SSS_Z];
            dateOld = [dateFormatOld dateFromString:strDate];
        }
        
        NSDate *currentDateNSDate = [NSDate date];
        NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        
        NSDateComponents *components = [gregorian components:unitFlags fromDate:dateOld toDate:currentDateNSDate options:0];
        
        NSInteger year = [components year];
        NSInteger months = [components month];
        NSInteger days = [components day];
        NSInteger hours = [components hour];
        NSInteger min = [components minute];
        NSInteger sec = [components second];
        
        if(year > 0)
        {
            return (year == 1) ? [NSString stringWithFormat:@"%d year ago",year] : [NSString stringWithFormat:@"%d years ago",year];
        }
        else if(months > 0)
        {
            return (months == 1) ? [NSString stringWithFormat:@"%d month ago",months] : [NSString stringWithFormat:@"%d months ago",months];
        }
        else if(days > 0)
        {
            return (days == 1) ? [NSString stringWithFormat:@"1 day ago"] : [NSString stringWithFormat:@"%d days ago",days];
        }
        else if(hours > 0)
        {
            return (hours == 1) ? [NSString stringWithFormat:@"%d hour ago",hours] : [NSString stringWithFormat:@"%d hours ago",hours];
            
        }
        else if(min > 0)
        {
            return (min == 1) ? [NSString stringWithFormat:@"%d minute ago",min]:[NSString stringWithFormat:@"%d minutes ago",min];
        }
        else if(sec > 0)
        {
            return [NSString stringWithFormat:@"few seconds ago"];
        }
    }
    return nil;
}

/**-----------------------------------------------------------------
 Function Name  : formatSearchDateWithTimeDurationFormat
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Takes the date as string and returns the calculated hours in string.
 ------------------------------------------------------------------*/

- (NSString *)formatSearchDateWithTimeDurationFormat : (NSString *)strDate
{
    if(strDate && [strDate length]>0)
    {
        ///format with normal format
        NSDateFormatter *dateFormatOld = [[NSDateFormatter alloc] init];
        [dateFormatOld setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatOld setDateFormat:kstryyyy_MM_dd_T_HH_mm_ss_Z];
        NSDate *dateOld = [dateFormatOld dateFromString:strDate];
        
        NSDateFormatter *dtfSearchFormat = [[NSDateFormatter alloc] init];
        [dtfSearchFormat setTimeZone:[NSTimeZone systemTimeZone]];
        [dtfSearchFormat setDateFormat:kDATEFORMATE_SEARCH_NEWS];
        
        if(!dateOld)
        {
            ///format with milisecond format
            [dateFormatOld setDateFormat:kstryyyy_MM_dd_T_HH_mm_ss_SSS_Z];
            dateOld = [dateFormatOld dateFromString:strDate];
        }
        
        NSDate *currentDateNSDate = [NSDate date];
        NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        
        NSDateComponents *components = [gregorian components:unitFlags fromDate:dateOld toDate:currentDateNSDate options:0];
        
        NSInteger year = [components year];
        NSInteger months = [components month];
        NSInteger days = [components day];
        NSInteger hours = [components hour];
        NSInteger min = [components minute];
        NSInteger sec = [components second];
        
        if(year > 0)
        {
            return [dtfSearchFormat stringFromDate:dateOld];
        }
        else if(months > 0)
        {
            return [dtfSearchFormat stringFromDate:dateOld];
        }
        else if(days > 0)
        {
            return (days == 1) ? [NSString stringWithFormat:@"1 day ago"] : [dtfSearchFormat stringFromDate:dateOld];
        }
        else if(hours > 0)
        {
            return (hours == 1) ? [NSString stringWithFormat:@"%d hour ago",hours] : [NSString stringWithFormat:@"%d hours ago",hours];
        }
        else if(min > 0)
        {
            return (min == 1) ? [NSString stringWithFormat:@"%d minute ago",min]:[NSString stringWithFormat:@"%d minutes ago",min];
        }
        else if(sec > 0)
        {
            return [NSString stringWithFormat:@"few seconds ago"];
        }
    }
    return nil;
}


- (NSString *)formatCommentLikeString:(NSString *)string
{
    if (string && string.length > 0)
    {
        if (string.intValue == 0)
        {
            // Do nothing...
        }
        else if (string.intValue == 1)
        {
            return @"1 Like  | ";
        }
        else if (string.intValue > 1)
        {
            return [NSString stringWithFormat:@"%@ Like  | ", string];
        }
    }
    
    return @"";
}

@end
