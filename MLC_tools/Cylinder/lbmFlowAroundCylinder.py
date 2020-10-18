# Flow Around a Cylinder (LBM)
#
# author: Rodrigo Castellanos. 
# Experimental Aerodynamics group at UC3M.
#
# 2D flow around a cylinder based on LBM solver.
#-----------------------------------------------------------------------------
# Import libraries:
from numpy import *
import matplotlib.pyplot as plt
from matplotlib import cm 
import sys

print('Number of arguments:', len(sys.argv), 'arguments.')
print('Argument List:', str(sys.argv))

freq=double(sys.argv[1]);
phase=double(sys.argv[2]);
ampl=double(sys.argv[3]);

###### Flow definition ########################################################
maxIter = 1000                 # Total number of time iterations.
Re      = 50                  # Reynolds number.
nx, ny  = 420, 180            # Numer of lattice nodes.
ly      = ny-1                # Height of the domain in lattice units.
cx,cy,r = nx//4, ny//2, ny//9 # Coordinates of the cylinder.
uLB     = 0.04                # Velocity in lattice units.
nulb    = uLB*r/Re;           # Viscoscity in lattice units.
omega   = 1 / (3*nulb+0.5);   # Relaxation parameter.

# Remember:
# Sound speed: cs²=1/3·dx²/dt²
# Pressure: p = cs²/rho
# Viscosity: nu = dt·cs²·(1/omega-1/2)
# Reynolds: Re = u·r/nu

###### Lattice Constants ######################################################
# Lattice velocities in the 2D lattice. We are using a D2Q9, that means:
# 2 dimensions with 9 possible vectors (north-east,east,south-east,north,origin,
# south,north-west,west,south-west)
v    = array([ [ 1,  1], [ 1,  0], [ 1, -1], [ 0,  1], [ 0,  0],
              [ 0, -1], [-1,  1], [-1,  0], [-1, -1] ])
# Weight factor of each direction: to compensate for the different lengths of
# velocities v[i]:
t    = array([ 1/36, 4/36, 1/36, 4/36, 16/36, 4/36, 1/36, 4/36, 1/36])
# Numbering the columns of the lattice:
col1 = array([0, 1, 2])
col2 = array([3, 4, 5])
col3 = array([6, 7, 8])

###### Function Definitions ###################################################
def macroscopic(fin):
    """ Ontain the macroscopic quantities of the population: U,rho"""
    rho = sum(fin, axis=0)
    u = zeros((2, nx, ny))
    for i in range(9):
        u[0,:,:] += v[i,0] * fin[i,:,:]
        u[1,:,:] += v[i,1] * fin[i,:,:]
    u /= rho
    return rho, u

def equilibrium(rho, u):
    """ Equilibrium distribution function: feq. The equilibrium is obtaines from
    a truncated series of Maxwell-Boltzmann distribution."""
    usqr = 3/2 * (u[0]**2 + u[1]**2)
    feq = zeros((9,nx,ny)) # f is a 3D array of 9states x nx nodes x ny nodes
    for i in range(9):
        cu = 3 * (v[i,0]*u[0,:,:] + v[i,1]*u[1,:,:])
        feq[i,:,:] = rho*t[i] * (1 + cu + 0.5*cu**2 - usqr)
    return feq

###### Setup: cylindrical obstacle and velocity inlet with perturbation #######
# Creation of a mask with 1/0 values, defining the shape of the obstacle.
def obstacle_fun(x, y):
    """ Definition of the obstacle location: circle of radius r and centered at
    (cx,cy). The function requires an x,y position as an input and it will return
    a true/false (1/0) value. True (1) corresponds to those positions that belongs
    to the obstacle. False (0) are the positions outside the obstacle """
    return (x-cx)**2+(y-cy)**2<r**2

obstacle = fromfunction(obstacle_fun, (nx,ny))

# Initial velocity profile: almost zero, with a slight perturbation to trigger
# the instability.
def inivel(d, x, y):
    return (1-d) * uLB * (1 + 1e-4*sin(y/ly*2*pi))

vel = fromfunction(inivel, (2,nx,ny))

# Initialization of the populations at equilibrium with the given velocity.
fin = equilibrium(1, vel)

###### Main time loop #########################################################
for time in range(maxIter):
    # Right wall: outflow condition.
    fin[col3,-1,:] = fin[col3,-2,:] 

    # Compute macroscopic variables, density and velocity.
    rho, u = macroscopic(fin)

    # Left wall: inflow condition.
    u[:,0,:] = vel[:,0,:]
    rho[0,:] = 1/(1-u[0,0,:]) * ( sum(fin[col2,0,:], axis=0) +
                                  2*sum(fin[col3,0,:], axis=0) )
    # Compute equilibrium.
    feq = equilibrium(rho, u)
    fin[[0,1,2],0,:] = feq[[0,1,2],0,:] + fin[[8,7,6],0,:] - feq[[8,7,6],0,:]

    # Collision step.
    fout = fin - omega * (fin - feq)

    # Bounce-back condition for obstacle.
    for i in range(9):
        fout[i, obstacle] = fin[8-i, obstacle]

	#Jet condition for up/down side of cylinder						
    fout[3,cx,cy-r] += ampl*sin(freq*time) #upper side(in the graph), suction
    fout[5,cx,cy+r] += ampl*sin(freq*time) #lower side(in the graph), blowing
	
    # Streaming step.
    for i in range(9):
        fin[i,:,:] = roll(roll(fout[i,:,:], v[i,0], axis=0),v[i,1], axis=1 )
	
    # Visualization of the velocity.
    #if (time%100==0):
        #plt.clf()
        #plt.imshow(u[1].transpose(), cmap=cm.Reds)
        #plt.savefig("vel.{0:04d}.png".format(time//100))

for i in range(9):
    filefin= 'fin' + str(i) + '.csv'
    savetxt(filefin, fin[i,:,:], delimiter=',')

savetxt('u.csv', u[0,:,:], delimiter=',')
savetxt('v.csv', u[1,:,:], delimiter=',')
savetxt('rho.csv', rho[:,:], delimiter=',')