// SPDX-License-Identifier: GPL-2.0
/*
 * Panic Test Module - Testing module to trigger a kernel panic and show it.
 * Copyright (C) 2024 - v38armageddon
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
#include <linux/module.h>
#include <linux/kernel.h>

static int panic_test_init(void) {
    printk(KERN_INFO "Panic Test Module loaded!\n");
    printk(KERN_INFO "Triggering kernel panic... NOW!\n");
    panic("Panic Test! Kernel panic triggered by panic_test module\n");
    return 0;
}

static void panic_test_exit(void) {
    printk(KERN_INFO "Panic Test Module unloaded\n");
}

module_init(panic_test_init);
module_exit(panic_test_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Florian. M");
MODULE_DESCRIPTION("Testing module to trigger a kernel panic and show it.");