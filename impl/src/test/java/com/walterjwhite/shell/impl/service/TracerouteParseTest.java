package com.walterjwhite.shell.impl.service;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.junit.Test;

public class TracerouteParseTest {

  private static final Pattern PATTERN =
      Pattern.compile("^([\\d]{1,})  ([\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3})  (.*)$");

  @Test
  public void testParsing() {
    // line 1 is a declaration of what we're doing, ignore it
    // each subsequent line may have an IP address / hostname (with an IP address) and n latency
    // records
    final String output =
        "traceroute to google.com (216.58.219.206), 30 hops max, 60 byte packets\n"
            + "1  10.30.0.1  0.182 ms  0.178 ms  0.178 ms\n"
            + "2  108.39.138.1  1.383 ms  1.388 ms  1.387 ms\n"
            + "3  100.41.217.26  3.114 ms  3.122 ms  3.122 ms\n"
            + "4  * * *\n"
            + "5  * * *\n"
            + "6  140.222.0.185  13.219 ms  13.055 ms  13.047 ms\n"
            + "7  204.148.79.46  12.513 ms  18.295 ms  18.298 ms\n"
            + "8  108.170.246.2  18.823 ms  17.116 ms  17.102 ms\n"
            + "9  209.85.240.63  17.388 ms  15.407 ms  14.989 ms\n"
            + "10  108.177.3.50  18.472 ms  18.474 ms  19.538 ms\n"
            + "11  216.239.56.16  18.340 ms  17.837 ms  17.823 ms\n"
            + "12  * * *\n"
            + "13  108.170.230.1  16.154 ms  20.280 ms  20.280 ms\n"
            + "14  216.58.219.206  14.702 ms  14.680 ms  14.684 ms\n";

    int index = 0;
    for (String line : output.split("\n")) {
      System.out.println("LINE:" + line);
      if (index > 0) {
        System.out.println("hop:" + line);

        line = line.trim().replace("ms", "");

        final Matcher matcher = PATTERN.matcher(line);
        if (matcher.matches()) {
          System.out.println("matches:" + line);
          System.out.println("hop:" + matcher.group(1));
          System.out.println("IP:" + matcher.group(2));

          for (final String hopTime : matcher.group(3).split("  ")) {
            System.out.println("time:" + Double.valueOf(hopTime));
          }
        } else {
          System.out.println("!matched:" + line);
        }
      }

      index++;
    }
  }
}
