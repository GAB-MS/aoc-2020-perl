#!/usr/bin/perl -w

package day1;

use strict;
use warnings;
use English;

my $LITERALLY_THE_WORST = 2020;

sub run
{
  my (undef, $xiInput) = @_;
  $xiInput or die "Requires input";
  return overengineered_solution($xiInput);
}

sub naive_solution
{
  my ($xiInput) = @_;
  my $xoAnswer = "";

  # This is the easy solution, using lots of for loops with no optimisation.
  # In addition to the nasty scaling with larger datasets, we'll try the same
  # set of two/three numbers multiple times as we loop through the same list
  # in each loop. And this will break for Task 1 if any input value is 1010,
  # as we'll add it to itself. The same bug is present in Task 2 if any value
  # can be doubled then added to one other value to make 2020.
  # But hey, this solution is simple and happens to just work with the dataset
  # given.

  $xoAnswer .= "TASK 1: ";

  NAIVE_TASK1:
  foreach my $lFirstNum (@$xiInput)
  {
    foreach my $lSecondNum (@$xiInput)
    {
      if ($lFirstNum + $lSecondNum == $LITERALLY_THE_WORST)
      {
        $xoAnswer .= "Selected $lFirstNum and $lSecondNum, product = " .
                                                      $lFirstNum * $lSecondNum;
        last NAIVE_TASK1;
      }
    }
  }

  $xoAnswer .= "\nTASK 2: ";

  NAIVE_TASK2:
  foreach my $lFirstNum (@$xiInput)
  {
    foreach my $lSecondNum (@$xiInput)
    {
      foreach my $lThirdNum (@$xiInput)
      {
        if ($lFirstNum + $lSecondNum + $lThirdNum == $LITERALLY_THE_WORST)
        {
          $xoAnswer .= "Selected $lFirstNum, $lSecondNum and $lThirdNum, " .
                          "product = " . $lFirstNum * $lSecondNum * $lThirdNum;
          last NAIVE_TASK2;
        }
      }
    }
  }

  return($xoAnswer);
}

sub better_solution
{
  my ($xiInput) = @_;
  my $xoAnswer = "";

  # Let's throw in some better optimisation - ensure we don't 're-use'
  # a number. We can do this by popping values from the list as we go. In
  # addition to being faster, this also gets rid of the bug mentioned in the
  # naive solution. We want to take a copy of the input data here so that we
  # can use the same data in the second task.

  $xoAnswer .= "TASK 1: ";
  my @lData = @$xiInput;

  BETTER_TASK1:
  while (@lData)
  {
    my $lFirstNum = pop(@lData);

    foreach my $lSecondNum (@lData)
    {
      if ($lFirstNum + $lSecondNum == $LITERALLY_THE_WORST)
      {
        $xoAnswer .= "Selected $lFirstNum and $lSecondNum, product = " .
                                                      $lFirstNum * $lSecondNum;
        last BETTER_TASK1;
      }
    }
  }

  $xoAnswer .= "\nTASK 2: ";
  @lData = @$xiInput;

  BETTER_TASK2:
  while (@lData)
  {
    my $lFirstNum = pop(@lData);

    # We need to copy the remaining data into another array here so that we
    # can properly cycle through the second and third numbers, again without
    # repeating any comparisons.
    my @lDataSlice = @lData;

    while (@lDataSlice)
    {
      my $lSecondNum = pop(@lDataSlice);

      foreach my $lThirdNum(@lDataSlice)
      {
        if ($lFirstNum + $lSecondNum + $lThirdNum == $LITERALLY_THE_WORST)
        {
          $xoAnswer .= "Selected $lFirstNum, $lSecondNum and $lThirdNum, " .
                          "product = " . $lFirstNum * $lSecondNum * $lThirdNum;
          last BETTER_TASK2;
        }
      }
    }
  }

  return($xoAnswer);
}

sub overengineered_solution
{
  my ($xiInput) = @_;
  my $xoAnswer = "";

  # This is where we get crazy. We can decrease the number of comparisons we
  # need to make, potentially drastically, by ensuring that we don't make
  # comparisons that obviously won't work. We can do some simple sorting
  # first, into a list of numbers larger than (2020/2), and a list of numbers
  # smaller than (2020/2). We know that two 'large' numbers will never sum to
  # 2020, and similarly nor will two 'small' numbers, so all we need to do is
  # compare 'large' numbers to 'small' numbers.
  # Sadly, (2020/2) is an integer itself, and needs a bit of special handling.

  $xoAnswer .= "TASK 1: ";
  my $lLargeNumbers = [];
  my $lSmolNumbers = [];
  my $lSliceOn = $LITERALLY_THE_WORST / 2;

  foreach my $lNum (@$xiInput)
  {
    my $lTargetList = ($lNum >= $lSliceOn) ? $lLargeNumbers : $lSmolNumbers;
    push(@$lTargetList, $lNum);
  }

  OVERENGINEERED_TASK1:
  while (@$lLargeNumbers)
  {
    my $lLargeNum = pop(@$lLargeNumbers);

    # Here's the special case handling for 1010 - if we have 1010 specifically
    # then compare it to the large list and not the small, as any other 1010s
    # will be in the large list.
    my $lTargetList = ($lLargeNum == $lSliceOn) ? $lLargeNumbers
                                                : $lSmolNumbers;

    foreach my $lSmolNum (@$lTargetList)
    {
      if ($lLargeNum + $lSmolNum == $LITERALLY_THE_WORST)
      {
        $xoAnswer .= "Selected $lLargeNum and $lSmolNum, product = " .
                                                        $lLargeNum * $lSmolNum;
        last OVERENGINEERED_TASK1;
      }
    }
  }

  # Now, how do we overengineer task 2? We can do something similar. If we
  # take 2020/3, and slice the list based on the result, we know that we need
  # either:
  # * Two 'large' numbers and one 'small' number
  # * One 'large' number and two 'small' numbers
  # as it's mathematically impossible to form 2020 from 3 numbers all larger,
  # or smaller, than 2020/3.
  # So: we start with one number from each list, sum the result, test if it's
  # larger or smaller than (2020/3)*2 which then tells us which list to draw
  # from for the third number.

  $xoAnswer .= "\nTASK 2: ";
  $lLargeNumbers = [];
  $lSmolNumbers = [];
  $lSliceOn = $LITERALLY_THE_WORST / 3;
  my $lInterimCheck = $lSliceOn * 2;

  foreach my $lNum (@$xiInput)
  {
    my $lTargetList = ($lNum >= $lSliceOn) ? $lLargeNumbers : $lSmolNumbers;
    push(@$lTargetList, $lNum);
  }

  OVERENGINEERED_TASK2:
  while (@$lLargeNumbers)
  {
    my $lLargeNum = pop(@$lLargeNumbers);
    my $lSmolNumbersCopy = [@$lSmolNumbers];

    while (@$lSmolNumbersCopy)
    {
      my $lSmolNum = pop(@$lSmolNumbersCopy);

      # Now choose which list we search for the potential third match.
      my $lInterimSum = $lLargeNum + $lSmolNum;
      my $lTargetList = ($lInterimSum <= $lInterimCheck) ? $lLargeNumbers
                                                         : $lSmolNumbersCopy;

      foreach my $lThirdNum (@$lTargetList)
      {
        if ($lInterimSum + $lThirdNum == $LITERALLY_THE_WORST)
        {
          $xoAnswer .= "Selected $lLargeNum, $lSmolNum and $lThirdNum, " .
                            "product = " . $lLargeNum * $lSmolNum * $lThirdNum;
          last OVERENGINEERED_TASK2;
        }
      }
    }
  }

  return($xoAnswer);
}

1;

__END__
