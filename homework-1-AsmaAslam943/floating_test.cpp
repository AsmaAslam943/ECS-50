#include <gtest/gtest.h>

extern "C"
{
#include "floating.h"
}

// Demonstrate some basic assertions.
TEST(HelloTest, BasicAssertions)
{
    // Expect two strings not to be equal.
    EXPECT_STRNE("hello", "world");
    // Expect equality.
    EXPECT_EQ(7 * 6, 42);
}

TEST(FloatingTest, BasicConversions)
{
    // This is true on almost EVERY architecture, but a bit of paranoia is
    // a Good Thing (tm)
    ASSERT_EQ(sizeof(float), 4) << "Can only run where \"float\" is 4 bytes";
    char info[100];
    floating f;
    uint16_t ieeehalf;
    f.as_float = -0.5;
    floating_info(f, info, 100);
    EXPECT_STREQ("-1.00000000000000000000000 2^-1", info);
    ieeehalf = as_ieee_16(f);
    EXPECT_EQ(ieeehalf, 0xb800);
    ieee_16_info(ieeehalf, info, 100);
    EXPECT_STREQ(info, "-1.0000000000 2^-1");
}

/*
TEST(HelloTest, KnownFailure) {
    EXPECT_TRUE(false) << "False is not true!";
} */
