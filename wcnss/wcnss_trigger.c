/* The built-in WCNSS driver loads its PIL firmware only on a userspace open.
 * The node has no write handler, so calibration data cannot be uploaded. */

#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

#define WCNSS_DEV "/dev/wcnss_wlan"

int main(void)
{
	int fd = open(WCNSS_DEV, O_RDONLY);

	if (fd < 0) {
		perror(WCNSS_DEV);
		return 1;
	}
	close(fd);
	return 0;
}
