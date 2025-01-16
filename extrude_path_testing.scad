include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

/* [Variables] */
size = [40, 6, 20];
thick = 2;
r1 = 5;
r2 = 0.5;

/* [Hidden] */
nill = 0.01;
$fs = 0.1;
$fn = $preview ? 20 : 200;

/*  [Calculated Values] */
2thick = 2*thick;
2nill = 2*nill;

path = [
    [0,      size.y],
    [0,      0],
    [size.x, 0],
    [size.x, size.y],
];

path_cnr = [
    [0,      size.y],
    [0,      0],
    [size.y, 0],
];

path2 = [
    [0+thick,      size.y+nill],
    [0+thick,      0+thick],
    [size.x-thick, 0+thick],
    [size.x-thick, size.y+nill],
];

module method1() {
    translate(v_div(size, [2, 2, 2])) difference() {
        cuboid(size, rounding=r1, edges=[LEFT+FRONT, RIGHT+FRONT]);
        back(thick) cuboid([size.x-2thick, size.y, size.z+2nill], rounding=r1-thick, edges=[LEFT+FRONT, RIGHT+FRONT]);
    }
    // Problem: can't do desired roundings on the cuboids
}

module method2() {
    linear_extrude(size.z) stroke(path, width=thick);
    // Problem: not rounded at all
}

module method3() {
    linear_extrude(size.z) stroke(round_corners(path, r=r1, closed=false), width=thick);
    // Problem: top/bottom not rounded
}

module method4() {
    offset_sweep(round_corners(path, r=r1, closed=false), height=size.z, top=os_circle(r=0.5));
    // Problem: offset_sweep ignores "closed=false"
}

module method5() {
    linear_extrude(size.z) stroke(round_corners(path, r=r1, closed=false), width=thick);
    up(size.z) path_sweep(circle(d=thick), round_corners(path, r=r1, closed=false), anchor=FRONT+LEFT+BOTTOM);
    // Problem: Doesn't line up nicely
    // Problem: Not rounded at the corners
}

module method6() {
     up(size.z/2) difference() {
        rounded_prism(
            round_corners(path, r=r1, closed=false),
            height = size.z,
            joint_top=r2,
            joint_bot=r2
        );
        magic = 1;
        down(nill) rounded_prism(
            round_corners(path2, r=r1-magic, closed=false),
            height = size.z+2nill,
            joint_top=-r2,
            joint_bot=-r2
        );
    }
    // Problem: requires magic
    // Problem: glitchy
    // Problem: doesn't round the corners (could be fixed by adding rounded cyls)
    // Problem: super-inefficient
}

module method7() {
     up(size.z/2) path_copies(round_corners(path, r=r1, closed=false), n=50) cyl(size.z, rounding=r2);
    // Problem: doesn't sequentially hull each instance, even with chain_hull() 
}

module bangle(d=20, id=10, a=45, h=10, rounding=4, only=false) {
    r = d/2;
    ir = id/2;
    t = r-ir;
    ht = t/2;
    hh = h/2;
    ha = a/2;

    module inner() {
        down(nill) color("white") cyl(d=id, h=h+2nill+2nill, rounding=-rounding);
        rotate_extrude(angle=a) right(r-ht) square([t+t, h+2nill, 0.1], center=true);
    }

    if(only == "inner") inner();

    rotate([0, 0, 90-ha]) {
        if(!only) difference() {
            cyl(d=d, h=h, rounding=rounding);
            inner();
        }
        if(!only || only=="left") hull() {
            rotate([0, 0, a]) right(ir+ht) up(hh) torus(od=t, d_maj=t-rounding-rounding, anchor=TOP);
            rotate([0, 0, a]) right(ir+ht) down(hh) torus(od=t, d_maj=t-rounding-rounding, anchor=BOTTOM);
        }
        if(!only || only=="right") hull() {
            rotate([0, 0, 0]) right(ir+ht) up(hh) torus(od=t, d_maj=t-rounding-rounding, anchor=TOP);
            rotate([0, 0, 0]) right(ir+ht) down(hh) torus(od=t, d_maj=t-rounding-rounding, anchor=BOTTOM);
        }
    }
}

module method8() {
    d = r1*2;
    id = d-2thick;
    up(size.z/2) {
        right(r1) zrot(-45) bangle(d=d, id=id, a=360-90, h=size.z, rounding=r2, only=false);
        right(size.x-r1) zrot(+45) bangle(d=d, id=id, a=360-90, h=size.z, rounding=r2, only=false);
        hull() {   
            right(r1) zrot(-45) bangle(d=d, id=id, a=360-90, h=size.z, rounding=r2, only="right");
            right(size.x-r1) zrot(+45) bangle(d=d, id=id, a=360-90, h=size.z, rounding=r2, only="left");
        }
    }
    // Problems: Doesn't use size.z (Could be fixed by adding another 2 hulls)
}

module method9() {
    shape = circle(d=thick);
    rounded_path = round_corners(path, r=r1, closed=false);
    path_sweep(shape, rounded_path);
    // Problem: Not sure how to make the correct shape
    // Problem: Not sure how to round the top
}

fwd(00) method1();
fwd(10) method2();
fwd(20) method3();
fwd(30) method4();
fwd(40) method5();
fwd(50) method6();
fwd(60) method7();
fwd(70) method8();
fwd(80) method9();
