// ##############################################################
//  DataFunctions.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Thu Jun 26 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "DataFunctions.h"
#import "BigCFloat.h"
#import "DataManager.h"
#import "DrawerManager.h"

//
// About DataFunctions
//
// The functions in this class perform all the functions on the data in the data
// drawers.
//
@implementation DataFunctions

//
// afromrankregressiononx
//
// Calculates the x intercept of the line of best fit calculated from variation in x direction
//
- (id)afromrankregressiononx:(NSMutableArray *)values
{
	BigCFloat *a = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *averagex = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *n = [BigCFloat bigFloatWithInt:(int)[values count] / 2 radix:[dataManager getRadix]];
	BigCFloat *m = [self mfromrankregressiononx:values];
	BigCFloat *b = [self bfromrankregressiononx:values];
	int			i;

	for (i = 0; i < [values count] / 2; i++)
	{
		[averagex add:values[i * 2]];
	}
	[averagex divideBy:n];

	[a subtract:b];
	[a divideBy:m];
	
	return a;
}

//
// afromrankregressionony
//
// Calculates the x intercept of the line of best fit calculated from variation in y direction
//
- (id)afromrankregressionony:(NSMutableArray *)values
{
	BigCFloat *a = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *averagex = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *n = [BigCFloat bigFloatWithInt:(int)[values count] / 2 radix:[dataManager getRadix]];
	BigCFloat *m = [self mfromrankregressionony:values];
	BigCFloat *b = [self bfromrankregressionony:values];
	int			i;

	for (i = 0; i < [values count] / 2; i++)
	{
		[averagex add:values[i * 2]];
	}
	[averagex divideBy:n];

	[a subtract:b];
	[a divideBy:m];
	
	return a;
}

//
// bfromrankregressiononx
//
// Calculates the y intercept of the line of best fit calculated from variation in x direction
//
- (id)bfromrankregressiononx:(NSMutableArray *)values
{
	BigCFloat *averagey = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *averagex = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *n = [BigCFloat bigFloatWithInt:(int)[values count] / 2 radix:[dataManager getRadix]];
	BigCFloat *m = [self bfromrankregressiononx:values];
	int			i;

	for (i = 0; i < [values count] / 2; i++)
	{
		[averagex add:values[i * 2]];
	}
	[averagex divideBy:n];

	for (i = 0; i < [values count] / 2; i++)
	{
		[averagey add:values[i * 2 + 1]];
	}
	[averagey divideBy:n];

	[averagex multiplyBy:m];
	[averagey subtract:averagex];
	
	return averagey;
}

//
// bfromrankregressionony
//
// Calculates the y intercept of the line of best fit calculated from variation in y direction
//
- (id)bfromrankregressionony:(NSMutableArray *)values
{
	BigCFloat *averagey = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *averagex = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *n = [BigCFloat bigFloatWithInt:(int)[values count] / 2 radix:[dataManager getRadix]];
	BigCFloat *m = [self mfromrankregressionony:values];
	int			i;

	for (i = 0; i < [values count] / 2; i++)
	{
		[averagex add:values[i * 2]];
	}
	[averagex divideBy:n];

	for (i = 0; i < [values count] / 2; i++)
	{
		[averagey add:values[i * 2 + 1]];
	}
	[averagey divideBy:n];

	[averagex multiplyBy:m];
	[averagey subtract:averagex];
	
	return averagey;
}

//
// coefofvariation
//
// Calculates the coefficient of variation
//
- (id)coefofvariation:(NSMutableArray *)values
{
	BigCFloat	*standardDeviation;
	BigCFloat	*mean;
	BigCFloat	*hundred;
	
	mean = [self mean:values];
	
	if ([mean isZero])
		return mean;
	
	standardDeviation = [self stddev:values];
	hundred = [BigCFloat bigFloatWithInt:100 radix:[dataManager getRadix]];
	
	[standardDeviation divideBy:mean];
	[standardDeviation multiplyBy:hundred];
	
	return standardDeviation;
}

//
// determinantsubmatrix
//
// A utility function used by determinant
//
- (NSMutableArray *)determinantsubmatrix:(NSMutableArray *)values size:(int)size withoutRow:(int)row orColumn:(int)column
{
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:(size - 1) * (size - 1)];
	int i, j;
	
	for (j = 0; j < size; j++)
	{
		for (i = 0; i < size; i++)
		{
			if (i == column || j == row)
				continue;
			
			[newArray addObject:values[j * size + i]];
		}
	}
	
	return newArray;
}

//
// determinant
//
// An internal recursive function. Calculates the determinant for the matrix.
//
- (BigCFloat *)determinant:(NSMutableArray *)values size:(int)size
{
	int i;
	BigCFloat *result = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *temp = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	
	if (size == 2)
	{
		[result add:values[0]];
		[result multiplyBy:values[3]];
		[temp add:values[1]];
		[temp multiplyBy:values[2]];
		[result subtract:temp];
		
		return result;
	}
	
	for (i = 0; i < size; i++)
	{
		[temp assign:values[i]];
		[temp multiplyBy:
			[self
				determinant:[self determinantsubmatrix:values size:size withoutRow:0 orColumn:i]
				size:size - 1
			]
		];
		
		if (i % 2 == 0)
			[result add:temp];
		else
			[result subtract:temp];
	}
	
	return result;
}

//
// determinant
//
// The external function to calculate the determinant.
//
- (id)determinant:(NSMutableArray *)values
{
	int num_rows, num_columns;
	
	[self prepareArray:values outColumns:&num_columns outRows:&num_rows];
	
	if (num_rows != num_columns) {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Can only get the determinant of a square matrix (a square matrix has the same number of columns as rows)"];
		[alert runModal];
//		[NSAlert alertWithMessageText:@"Can only get the determinant of a square matrix (a square matrix has the same number of columns as rows)"
//						defaultButton:NSAlertDefaultReturn
//					  alternateButton:nil
//						  otherButton:nil
//			informativeTextWithFormat:nil
//		 ];
		return nil;
	}

	return [self determinant:values size:num_rows];
}

//
// exchangeRows
// 
// Internal function used for gaussian elimination
//
- (void)exchangeRows:(NSMutableArray *)values firstRow:(int)one secondRow:(int)two columns:(int)numColumns
{
	BigCFloat *temp = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	int i;
	
	if (one == two)
		return;
	
	for (i = 0; i < numColumns; i++)
	{
		[temp assign:values[(one * numColumns) + i]];
		[values[(one * numColumns) + i] assign:values[(two * numColumns) + i]];
		[values[(two * numColumns) + i] assign:temp];
	}
}

//
// gaussianelimination
//
// Internally callable only. Reduces the matrix to its triangular form.
//
- (id)gaussianelimination:(NSMutableArray *)values columns:(int)numColumns rows:(int)numRows
{
	int numInconsistent = 0;
	int start_row = 0;
	int start_column = 0;
	int i, j;
	BigCFloat *one = [BigCFloat bigFloatWithInt:1 radix:[dataManager getRadix]];
	BigCFloat *zero = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *subtractor = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];

	// The gaussian elimination begins here
	while (start_row < numRows && start_column < numColumns - 1)
	{
		// Check the top-leftmost value for a zero
		if ([values[start_row * numColumns + start_column] isZero])
		{
			// If we have a zero at this point, move a lower row (without a zero) up
			for (i = start_row + 1; i < numRows; i++)
			{
				if (![values[i * numColumns + start_column] isZero])
				{
					[self exchangeRows:values firstRow:i secondRow:start_row columns:numColumns];
					break;
				}
			}
			
			// We found no non-zero values. This column is empty from here down.
			if (i == numRows)
			{
				// Ignore this column and move on to the next
				start_column++;
				continue;
			}
		}

		// Divide this row through by its leftmost value
		for (i = start_column + 1; i < numColumns; i++)
		{
			[values[start_row * numColumns + i] divideBy:values[start_row * numColumns + start_column]];
		}
		
		// Set the leftmost value to one
		[values[start_row * numColumns + start_column] assign:one];
		
		// We now clear this value from all subsequent rows
		for (j = start_row + 1; j < numRows; j++)
		{
			// The value to be cleared is zero in this row
			if ([values[j * numColumns + start_column] isZero])
				continue;
			
			// Subtract the "start_row"th row times (start_column, j) from the j-th row
			for (i = start_column + 1; i < numColumns; i++)
			{
				[subtractor assign:values[j * numColumns + start_column]];
				[subtractor multiplyBy:values[start_row * numColumns + i]];
				
				[values[j * numColumns + i] subtract:subtractor];
			}
			[values[j * numColumns + start_column] assign:zero];
		}
		
		// We have now cleared this row and column combination. Move on to the next
		start_row++;
		start_column++;
	}
	
	// Look for a zero row and move it down to the bottom
	for (j = 0; j < numRows; j++)
	{
		BOOL	emptyRow = YES;
		BOOL	emptyRowButForLast = YES;
		
		for (i = 0; i < numColumns - 1; i++)
		{
			if (![(BigCFloat *)values[(j * numColumns) + i] isZero])
			{
				emptyRowButForLast = NO;
				break;
			}
		}
		if (emptyRowButForLast && [(BigCFloat *)values[(j * numColumns) + numColumns - 1] isZero])
			emptyRow = YES;
		else
			emptyRow = NO;
		
		if (emptyRow)
		{
			[self exchangeRows:values firstRow:j secondRow:numRows - 1 columns:numColumns];
			numRows--;
		}
		else if (emptyRowButForLast)
		{
			[self exchangeRows:values firstRow:j secondRow:numRows - 1 - numInconsistent columns:numColumns];
			numInconsistent++;
		}
	}
	
	return nil;
}

//
// gaussianelimination
//
// Externally callable function to perform gaussian elimination
//
- (id)gaussianelimination:(NSMutableArray *)values
{
	int numColumns, numRows;

	[self prepareArray:values outColumns:&numColumns outRows:&numRows];
	
	return [self gaussianelimination:values columns:numColumns rows:numRows];
}

//
// backsub
//
// Internal utility function. Performs backsubstitution to solve the matrix.
//
- (id)backsub:(NSMutableArray *)values columns:(int)num_columns rows:(int)num_rows
{
	int first_non_zero;
	int i, j, k;

	BigCFloat *one = [BigCFloat bigFloatWithInt:1 radix:[dataManager getRadix]];
	BigCFloat *zero = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *subtractor = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	
	// Backsub all rows that we can
	for (j = num_rows - 1; j >= 0; j--)
	{
		first_non_zero = -1;
		for (i = 0; i < num_columns - 1; i ++)
		{
			if (![(BigCFloat *)values[(j * num_columns) + i] isZero])
			{
				if (first_non_zero == -1)
				{
					first_non_zero = i;
					break;
				}
			}
		}
		
		if (first_non_zero != -1)
		{
			// Ensure that the non-zero value is equal to one
			if ([(BigCFloat *)values[(j * num_columns) + first_non_zero] compareWith:one] != NSOrderedSame)
			{
				[(BigCFloat *)values[(j * num_columns) + num_columns - 1] divideBy:(BigCFloat *)values[(j * num_columns) + first_non_zero]];
				
				[(BigCFloat *)values[(j * num_columns) + first_non_zero] assign:one];
			}
			
			// Eliminate this value from all rows above this
			for (k = j - 1; k >= 0; k--)
			{
				for (i = first_non_zero + 1; i < num_columns; i++)
				{
					[subtractor assign:(BigCFloat *)values[(j * num_columns) + i]];
					[subtractor multiplyBy:(BigCFloat *)values[(k * num_columns) + first_non_zero]];				
					[(BigCFloat *)values[(k * num_columns) + i] subtract:subtractor];
				}
				[(BigCFloat *)values[(k * num_columns) + first_non_zero] assign:zero];
			}
		}
	}
	
	return nil;
}

//
// gaussianeliminationwithbacksub
//
// Externally callable function to fully solve a matrix
//
- (id)gaussianeliminationwithbacksub:(NSMutableArray *)values
{
	int numRows, numColumns;
	
	[self prepareArray:values outColumns:&numColumns outRows:&numRows];	
	[self gaussianelimination:values columns:numColumns rows:numRows];
	
	return [self backsub:values columns:numColumns rows:numRows];
}

//
// inverse
//
// Inverts a matrix. Does it by extending the matrix with a triangular matrix, gaussian
// eliminating the extended matrix and taking the values from the appended region.
//
- (id)inverse:(NSMutableArray *)values
{
	int num_rows, num_columns;
	int i, j;
	NSMutableArray *solution;
	BOOL inverse_exists;
	
	BigCFloat *one = [BigCFloat bigFloatWithInt:1 radix:[dataManager getRadix]];
	BigCFloat *zero = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];

	[self prepareArray:values outColumns:&num_rows outRows:&num_columns];	
	
	if (num_rows != num_columns)
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Can only get the inverse of a square matrix (a square matrix has the same number of columns as rows)"];
		[alert runModal];
//		NSRunAlertPanel(nil, @"Can only get the inverse of a square matrix (a square matrix has the same number of columns as rows)", nil, nil, nil);
		return nil;
	}
	
	solution = [NSMutableArray arrayWithCapacity:(num_rows * num_columns * 2)];

	for (j = 0; j < num_rows; j++)
	{
		for (i = 0; i < num_columns; i++)
		{
			[solution addObject:[values[j * num_columns + i] duplicate]];
		}
		for (i = 0; i < num_columns; i++)
		{
			if (i == j)
				[solution addObject:[one duplicate]];
			else
				[solution addObject:[zero duplicate]];
		}
	}
	
	[self gaussianelimination:solution columns:num_columns * 2 rows:num_rows];
	[self backsub:solution columns:num_columns * 2 rows:num_rows];
	
	inverse_exists = YES;
	for (j = 0; j < num_rows; j++)
	{
		for (i = 0; i < num_columns; i++)
		{
			if (i == j)
			{
				if ([solution[j * num_columns * 2 + i] compareWith:one] != NSOrderedSame)
				{
					inverse_exists = NO;
					break;
				}
			}
			else
			{
				if ([solution[j * num_columns * 2 + i] compareWith:zero] != NSOrderedSame)
				{
					inverse_exists = NO;
					break;
				}
			}
		}
	}
	
	if (!inverse_exists)
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"The matrix is not invertible."];
		[alert runModal];
//		NSRunAlertPanel(nil, @"The matrix is not invertible.", nil, nil, nil);
		return nil;
	}
	
	for (j = 0; j < num_rows; j++)
	{
		for (i = 0; i < num_columns; i++)
		{
			[(BigCFloat *)values[j * num_columns + i] assign:(BigCFloat*)solution[j * num_columns * 2 + num_columns+ i]];
		}
	}
	
	return nil;
}

//
// mean
//
// Averages values.
//
- (id)mean:(NSMutableArray *)values
{
	BigCFloat	*sum;
	BigCFloat	*total;
	int			numValues = (int)[values count];
	int			i;
	
	sum = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	total = [BigCFloat bigFloatWithInt:numValues radix:[dataManager getRadix]];
	
	for (i = 0; i < numValues; i++)
	{
		[sum add:values[i]];
	}
	[sum divideBy:total];
	
	return sum;
}

- (id)median:(NSMutableArray *)values
{
	NSMutableArray *sortedValues;
	BigCFloat *median;
	BigCFloat *two = [BigCFloat bigFloatWithInt:2 radix:[dataManager getRadix]];
	
	if ([values count] == 0)
	{
		return [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	}
	
	sortedValues = [NSMutableArray arrayWithCapacity:[values count]];
	[sortedValues addObjectsFromArray:values];
	[sortedValues sortUsingSelector:@selector(compareWith:)];
	
	if ([values count] % 2 == 1)
		return sortedValues[([values count] - 1) / 2];
	
	median = (BigCFloat *)[sortedValues[([values count] - 1) / 2] duplicate];
	[median add:sortedValues[1 + ([values count] - 1) / 2]];
	[median divideBy:two];
	
	return median;
}

//
// mfromrankregressiononx
//
// Slope of the line of best fit (values calculated based on horizontal distance).
//
- (id)mfromrankregressiononx:(NSMutableArray *)values
{
	BigCFloat *nth_product_of_sums = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *sumysquared = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *sumx = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *sumy = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *sum_of_products = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *product = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *n = [BigCFloat bigFloatWithInt:(int)[values count] / 2 radix:[dataManager getRadix]];
	BigCFloat *numerator = [BigCFloat bigFloatWithInt:(int)[values count] radix:[dataManager getRadix]];
	BigCFloat *denominator = [BigCFloat bigFloatWithInt:(int)[values count] radix:[dataManager getRadix]];
	int			i;
	
	for (i = 0; i < [values count] / 2; i++)
	{
		[product assign:values[i * 2]];
		[product multiplyBy:values[i * 2 + 1]];
		[sum_of_products add:product];
	}

	for (i = 0; i < [values count] / 2; i++)
	{
		[product assign:values[i * 2 + 1]];
		[product multiplyBy:values[i * 2 + 1]];
		[sumysquared add:product];
	}

	for (i = 0; i < [values count] / 2; i++)
	{
		[sumx add:values[i * 2]];
	}

	for (i = 0; i < [values count] / 2; i++)
	{
		[sumy add:values[i * 2 + 1]];
	}
	
	[nth_product_of_sums assign:sumx];
	[nth_product_of_sums add:sumy];
	[nth_product_of_sums divideBy:n];
	
	[sumy multiplyBy:sumy];
	[sumy divideBy:n];
	
	[numerator assign:sum_of_products];
	[numerator subtract:nth_product_of_sums];
	[denominator assign:sumysquared];
	[denominator subtract:sumy];
	
	[denominator divideBy:numerator];
	
	return denominator;
}

//
// mfromrankregressiononxwithoriginintercept
//
// Slope of the line of best fit (values calculated based on horizontal distance). Assumes
// intercepts at the origin.
//
- (id)mfromrankregressiononxwithoriginintercept:(NSMutableArray *)values
{
	BigCFloat *sumysquared = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *sum_of_products = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *product = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	int			i;
	
	for (i = 0; i < [values count] / 2; i++)
	{
		[product assign:values[i * 2]];
		[product multiplyBy:values[i * 2 + 1]];
		[sum_of_products add:product];
	}

	for (i = 0; i < [values count] / 2; i++)
	{
		[product assign:values[i * 2 + 1]];
		[product multiplyBy:values[i * 2 + 1]];
		[sumysquared add:product];
	}
	
	[sumysquared divideBy:sum_of_products];
	
	return sumysquared;
}

//
// mfromrankregressionony
//
// Slope of the line of best fit (values calculated based on vertical distance).
//
- (id)mfromrankregressionony:(NSMutableArray *)values
{
	BigCFloat *nth_product_of_sums = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *sumxsquared = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *sumx = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *sumy = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *sum_of_products = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *product = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *n = [BigCFloat bigFloatWithInt:(int)[values count] / 2 radix:[dataManager getRadix]];
	BigCFloat *numerator = [BigCFloat bigFloatWithInt:(int)[values count] radix:[dataManager getRadix]];
	BigCFloat *denominator = [BigCFloat bigFloatWithInt:(int)[values count] radix:[dataManager getRadix]];
	int			i;
	
	for (i = 0; i < [values count] / 2; i++)
	{
		[product assign:values[i * 2]];
		[product multiplyBy:values[i * 2 + 1]];
		[sum_of_products add:product];
	}

	for (i = 0; i < [values count] / 2; i++)
	{
		[product assign:values[i * 2]];
		[product multiplyBy:values[i * 2]];
		[sumxsquared add:product];
	}

	for (i = 0; i < [values count] / 2; i++)
	{
		[sumx add:values[i * 2]];
	}

	for (i = 0; i < [values count] / 2; i++)
	{
		[sumy add:values[i * 2 + 1]];
	}
	
	[nth_product_of_sums assign:sumx];
	[nth_product_of_sums multiplyBy:sumy];
	[nth_product_of_sums divideBy:n];
	
	[sumx multiplyBy:sumx];
	[sumx divideBy:n];
	
	[numerator assign:sum_of_products];
	[numerator subtract:nth_product_of_sums];
	[denominator assign:sumxsquared];
	[denominator subtract:sumx];
	
	[numerator divideBy:denominator];
	
	return numerator;
}

//
// mfromrankregressiononywithoriginintercept
//
// Slope of the line of best fit (values calculated based on vertical distance). Assumes
// intercepts at the origin.
//
- (id)mfromrankregressiononywithoriginintercept:(NSMutableArray *)values
{
	BigCFloat *sumxsquared = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *sum_of_products = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	BigCFloat *product = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	int			i;
	
	for (i = 0; i < [values count] / 2; i++)
	{
		[product assign:values[i * 2]];
		[product multiplyBy:values[i * 2 + 1]];
		[sum_of_products add:product];
	}

	for (i = 0; i < [values count] / 2; i++)
	{
		[product assign:values[i * 2]];
		[product multiplyBy:values[i * 2]];
		[sumxsquared add:product];
	}
	
	[sum_of_products divideBy:sumxsquared];
	
	return sum_of_products;
}

//
// mode
//
// Returns the mode commonly occuring value in the data set.
//
- (id)mode:(NSMutableArray *)values
{
	int	*valueCounts = (int *)malloc(sizeof(int) * [values count]);
	int	i, j;
	int modeIndex;
	
	if ([values count] == 0)
	{
		free(valueCounts);
		return [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	}
	
	for (i = 0; i < [values count]; i++)
	{
		valueCounts[i] = 0;
		for (j = i; j < [values count]; j++)
		{
			if ([values[i] compareWith:values[j]] == NSOrderedSame)
			{
				valueCounts[i]++;
			}
		}
	}
	
	modeIndex = 0;
	for (i = 1; i < [values count]; i++)
	{
		if (valueCounts[i] > valueCounts[modeIndex])
			modeIndex = i;
	}
	
	free(valueCounts);
	return values[modeIndex];
}

//
// prepareArray
//
// Makes certain that the rows and columns exist and are filled.
//
- (void)prepareArray:(NSMutableArray *)values outColumns:(int *)columns outRows:(int *)rows
{
	int numColumns = [drawerManager numberOfArrayColumns];
	int numRows;
	BigCFloat *zero = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	
	while ([values count] % numColumns != 0)
	{
		[values addObject:zero];
	}
	numRows = (int)[values count] / numColumns;
	
	*columns = numColumns;
	*rows = numRows;
}

//
// stddev
//
// Calculates the standard deviation of the values
//
- (id)stddev:(NSMutableArray *)values
{
	BigCFloat	*variance = [self variance:values];
	
	[variance sqrt];
	
	return variance;
}

//
// sum
//
// Calculates the sum of all the values
//
- (id)sum:(NSMutableArray *)values
{
	BigCFloat	*sum = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	int			i;
	
	for (i = 0; i < [values count]; i++)
	{
		[sum add:values[i]];
	}
	
	return sum;
}

//
// variance
//
// Calculates the variance of the values.
//
- (id)variance:(NSMutableArray *)values
{
	BigCFloat	*mean;
	BigCFloat	*term1;
	BigCFloat	*term2;
	BigCFloat	*term3;
	int			i;
	
	if ([values count] == 0 || [values count] == 1)
	{
		return [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	}
	
	mean = [self mean:values];
	
	term1 = [BigCFloat bigFloatWithInt:(int)[values count] - 1 radix:[dataManager getRadix]];
	[term1 inverse];
	
	term3 = [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
	
	for (i = 0; i < [values count]; i++)
	{
		term2 = (BigCFloat*)[values[i] duplicate];
		[term2 subtract:mean];
		[term2 multiplyBy:term2];
		
		[term3 add:term2];
	}
	
	[term3 multiplyBy:term1];
	
	return term3;
}

//
// zero
//
// Returns a zero. Its a debug function.
//
- (id)zero:(NSMutableArray *)values
{
	return [BigCFloat bigFloatWithInt:0 radix:[dataManager getRadix]];
}


@end
