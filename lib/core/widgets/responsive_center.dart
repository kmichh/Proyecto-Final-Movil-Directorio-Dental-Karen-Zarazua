import 'package:flutter/material.dart';

// Centra el contenido y limita su ancho máximo.
// En un teléfono no se nota, pero en tablet o en horizontal evita
// que las tarjetas se estiren demasiado (requisito de adaptabilidad).
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 700,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
