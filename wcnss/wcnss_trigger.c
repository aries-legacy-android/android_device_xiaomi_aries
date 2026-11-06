/* Opening the node triggers PIL; the node has no write handler, so calibration
 * data cannot be uploaded. GB init does not expand ${property} in write, so the
 * serial number is plumbed into the driver here. */

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <cutils/properties.h>

#define WCNSS_DEV "/dev/wcnss_wlan"
#define WCNSS_SERIAL "/sys/devices/platform/wcnss_wlan.0/serial_number"

int main(void)
{
	char serial[PROPERTY_VALUE_MAX];
	int fd = open(WCNSS_DEV, O_RDONLY);

	if (fd < 0) {
		perror(WCNSS_DEV);
		return 1;
	}
	close(fd);

	property_get("ro.serialno", serial, "00000000");
	fd = open(WCNSS_SERIAL, O_WRONLY);
	if (fd < 0) {
		perror(WCNSS_SERIAL);
		return 1;
	}
	if (write(fd, serial, strlen(serial)) < 0) {
		perror(WCNSS_SERIAL);
		close(fd);
		return 1;
	}
	close(fd);
	return 0;
}
