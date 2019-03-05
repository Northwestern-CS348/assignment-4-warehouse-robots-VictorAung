(define (domain warehouse)
	(:requirements :typing)
	(:types robot pallette - bigobject
        	location shipment order saleitem)

  	(:predicates
    	(ships ?s - shipment ?o - order)
    	(orders ?o - order ?si - saleitem)
    	(unstarted ?s - shipment)
    	(started ?s - shipment)
    	(complete ?s - shipment)
    	(includes ?s - shipment ?si - saleitem)

    	(free ?r - robot)
    	(has ?r - robot ?p - pallette)

    	(packing-location ?l - location)
    	(packing-at ?s - shipment ?l - location)
    	(available ?l - location)
    	(connected ?l - location ?l - location)
    	(at ?bo - bigobject ?l - location)
    	(no-robot ?l - location)
    	(no-pallette ?l - location)

    	(contains ?p - pallette ?si - saleitem)
  )

   (:action startShipment
      :parameters (?s - shipment ?o - order ?l - location)
      :precondition (and (unstarted ?s) (not (complete ?s)) 
                    (ships ?s ?o) (available ?l) (packing-location ?l))
      :effect (and (started ?s) (packing-at ?s ?l) (not (unstarted ?s)) 
              (not (available ?l)))
   )
   
    (:action robotMove
      :parameters (?source - location ?dest - location ?r - robot)
      :precondition (and (at ?r ?source) 
                         (no-robot ?dest) 
                         (not (at ?r ?dest)) 
                         (connected ?source ?dest))
      :effect (and (not (at ?r ?source))
                   (at ?r ?dest)
                   (no-robot ?source)
                   (not (no-robot ?dest)))
   )


   (:action robotMoveWithPallette
      :parameters (?source - location ?dest - location ?r - robot ?p - pallette)
      :precondition (and (or (free ?r) (has ?r ?p))
                         (connected ?source ?dest)
                         (at ?r ?source)
                         (at ?p ?source)
                         (no-robot ?dest)
                         (no-pallette ?dest))
      :effect (and (has ?r ?p) 
                   (not (at ?r ?source)) (not (at ?p ?source))
                   (at ?p ?dest) (no-pallette ?source) (not (no-pallette ?dest))
                   (at ?r ?dest) (no-robot ?source) (not (no-robot ?dest)))
   )

   (:action moveItemFromPalletteToShipment
     :parameters (?l - location ?s - shipment ?saleitem - saleitem ?p - pallette ?o - order)
     :precondition (and (at ?p ?l) (contains ?p ?saleitem) (packing-at ?s ?l) (packing-location ?l) (orders ?o ?saleitem) (ships ?s ?o) (not (complete ?s)) 
                   (not (includes ?s ?saleitem)))
     :effect (and (not (contains ?p ?saleitem)) (includes ?s ?saleitem))
   )

   (:action completeShipment
     :parameters (?s - shipment ?o - order ?l - location)
     :precondition (and (packing-at ?s ?l) (started ?s) (ships ?s ?o) (not (complete ?s)))
     :effect (and (complete ?s) (available ?l))
   )
)
