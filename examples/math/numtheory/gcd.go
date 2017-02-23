package numtheory

//// returns GCD(a,b) and a solution of ax + by = GCD(a,b)
func ExtendedGcd(a, b int64) (int64, int64, int64) {

	if b > a {
		d, x, y := ExtendedGcd(b, a)
		return d, y, x
	}

	var (
		r  int64 = 1
		x0 int64 = 1
		x1 int64 = 0
		y0 int64 = 0
		y1 int64 = 1
		q  int64
		x2 int64
		y2 int64
	)
	// r[-1] = a, r[0] = b, so r[0] = 0 * a + 1 * b ->
	for r > 0 {
		r = a % b
		q = a / b
		x2 = x0 - q*x1
		y2 = y0 - q*y1
		a = b
		b = r
		x0, y0, x1, y1 = x1, y1, x2, y2
		//log.Printf("%d %d %d %d %d %d\n", r, q, x0, y0, x1, y1)
	}
	return a, x0, y0
}
